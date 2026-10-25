//! API del motor que usa la app: listar carpetas, indexar, buscar y espacio
//! usado. Lo pesado corre en hilos de Rust; el progreso llega por streams.

use std::fs;
use std::path::Path;
use std::sync::Mutex;
use std::time::Instant;

use anyhow::{anyhow, Result};

use crate::frb_generated::StreamSink;
use crate::index::{self, Index, INDEX};

/// Un archivo o carpeta.
#[derive(Clone)]
pub struct FileItem {
    pub path: String,
    pub name: String,
    pub is_dir: bool,
    /// Bytes del archivo. En carpetas, lo que ocupan con sus subcarpetas
    /// según el índice (0 si todavía no hay índice).
    pub size: i64,
    pub modified_secs: i64,
    /// Elementos visibles dentro de una carpeta. Llega en una segunda parte.
    pub child_count: Option<u32>,
}

pub struct IndexInfo {
    /// Última puesta al día; 0 si nunca se ha indexado.
    pub indexed_at: i64,
    /// Último recorrido completo; 0 si nunca.
    pub full_at: i64,
    pub entries: u32,
    /// Cuánto tardó la última puesta al día en esta sesión (0 si ninguna).
    pub took_ms: u32,
}

pub struct IndexProgress {
    pub scanned: u32,
    pub done: bool,
    pub info: Option<IndexInfo>,
}

pub struct ExtensionUsage {
    pub extension: String,
    pub bytes: i64,
    pub files: u32,
}

pub struct StorageUsage {
    pub total_bytes: i64,
    pub files: u32,
    pub dirs: u32,
    pub by_extension: Vec<ExtensionUsage>,
    /// Hijos directos, del más pesado al más ligero.
    pub children: Vec<FileItem>,
}

/// Dónde se guarda el índice y qué carpetas raíz cubre; lo fija `engine_open`.
static CONFIG: Mutex<Option<(String, Vec<String>)>> = Mutex::new(None);

fn config() -> Result<(String, Vec<String>)> {
    CONFIG.lock().unwrap().clone().ok_or_else(|| anyhow!("engine_open no se ha llamado"))
}

pub(crate) fn info_of(index: &Index) -> IndexInfo {
    IndexInfo {
        indexed_at: index.indexed_at,
        full_at: index.full_at,
        entries: index.entries.len() as u32,
        took_ms: index.took_ms,
    }
}

fn item_of(e: &index::Entry, size: u64) -> FileItem {
    FileItem {
        path: e.path.clone(),
        name: e.name.clone(),
        is_dir: e.is_dir,
        size: size as i64,
        modified_secs: e.mtime,
        child_count: None,
    }
}

/// Prepara el motor para indexar `roots` (almacenamiento interno y tarjetas
/// SD) y carga el índice guardado, si es de esas mismas raíces.
pub fn engine_open(db_path: String, roots: Vec<String>) -> Result<IndexInfo> {
    *CONFIG.lock().unwrap() = Some((db_path.clone(), roots.clone()));
    let loaded = index::load(&db_path, &roots)?;
    let info = loaded
        .as_ref()
        .map(info_of)
        .unwrap_or(IndexInfo { indexed_at: 0, full_at: 0, entries: 0, took_ms: 0 });
    *INDEX.write().unwrap() = loaded;
    Ok(info)
}

/// Indexa todo `root` desde cero y lo guarda. Mientras tanto, la búsqueda
/// sigue usando el índice anterior.
pub fn index_build(sink: StreamSink<IndexProgress>) -> Result<()> {
    let (db_path, roots) = config()?;
    let started = Instant::now();
    let mut entries = Vec::new();
    let mut dir_sizes = std::collections::HashMap::new();
    for root in &roots {
        let before = entries.len();
        let (found, _) = index::walk(Path::new(root), |scanned| {
            let scanned = (before + scanned) as u32;
            let _ = sink.add(IndexProgress { scanned, done: false, info: None });
        });
        dir_sizes.extend(index::dir_sizes(root, &found));
        entries.extend(found);
    }
    let now = index::now_secs();
    let took_ms = started.elapsed().as_millis() as u32;
    let built = Index { roots, entries, dir_sizes, indexed_at: now, full_at: now, took_ms };
    index::save(&db_path, &built)?;
    let info = info_of(&built);
    let scanned = info.entries;
    *INDEX.write().unwrap() = Some(built);
    let _ = sink.add(IndexProgress { scanned, done: true, info: Some(info) });
    Ok(())
}

/// Pone al día el índice cargado sin recorrer todo: solo se leen las
/// carpetas cuya fecha cambió (ver `index::changes`). Mientras busca los
/// cambios, la búsqueda sigue funcionando. None si no hay índice.
pub fn index_update() -> Result<Option<IndexInfo>> {
    let (db_path, _) = config()?;
    let started = Instant::now();
    let found = {
        let guard = INDEX.read().unwrap();
        let Some(index) = guard.as_ref() else { return Ok(None) };
        index::changes(index)
    };
    let mut guard = INDEX.write().unwrap();
    let Some(index) = guard.as_mut() else { return Ok(None) };
    index::apply(index, &found);
    index.indexed_at = index::now_secs();
    index.took_ms = started.elapsed().as_millis() as u32;
    let dirs: Vec<String> = found.dirs.into_iter().map(|(p, _)| p).collect();
    index::save_paths(&db_path, index, &found.paths, &dirs)?;
    Ok(Some(info_of(index)))
}

/// Busca por nombre en todo el índice, o solo dentro de `within`. Los ocultos
/// solo con `include_hidden`.
pub fn search(
    query: String,
    within: Option<String>,
    include_hidden: bool,
    limit: u32,
) -> Vec<FileItem> {
    let guard = INDEX.read().unwrap();
    let Some(index) = guard.as_ref() else { return Vec::new() };
    index::search(index, &query, within.as_deref(), include_hidden, limit as usize)
        .into_iter()
        .map(|i| {
            let e = &index.entries[i];
            let size = if e.is_dir { index.dir_sizes.get(&e.path).copied().unwrap_or(0) } else { e.size };
            item_of(e, size)
        })
        .collect()
}

/// Espacio usado dentro de `path`. Lo indexado sale del índice (None si
/// todavía no hay). Lo que no se indexa, como un USB, se recorre en el momento.
pub fn storage_usage(path: String) -> Option<StorageUsage> {
    let indexed = config()
        .map(|(_, roots)| roots.iter().any(|r| index::is_within(r, &path)))
        .unwrap_or(false);
    if !indexed {
        return Some(usage_of(&index::scan(&path), &path));
    }
    let guard = INDEX.read().unwrap();
    Some(usage_of(guard.as_ref()?, &path))
}

/// Archivos dentro de `path` con alguna de `extensions` (sin punto, en
/// minúsculas; vacía es sin extensión), del más pesado al más ligero. Como
/// `storage_usage`: del índice, o recorriendo en el momento lo no indexado.
pub fn files_by_extension(path: String, extensions: Vec<String>, limit: u32) -> Option<Vec<FileItem>> {
    let extensions: std::collections::HashSet<String> = extensions.into_iter().collect();
    let pick = |index: &Index| -> Vec<FileItem> {
        index::files_with_extensions(index, &path, &extensions, limit as usize)
            .into_iter()
            .map(|i| item_of(&index.entries[i], index.entries[i].size))
            .collect()
    };
    let indexed = config()
        .map(|(_, roots)| roots.iter().any(|r| index::is_within(r, &path)))
        .unwrap_or(false);
    if !indexed {
        return Some(pick(&index::scan(&path)));
    }
    let guard = INDEX.read().unwrap();
    Some(pick(guard.as_ref()?))
}

fn usage_of(index: &Index, path: &str) -> StorageUsage {
    let usage = index::usage(index, path);
    let mut by_extension: Vec<ExtensionUsage> = usage
        .by_extension
        .into_iter()
        .map(|(extension, (bytes, files))| ExtensionUsage { extension, bytes: bytes as i64, files })
        .collect();
    by_extension.sort_unstable_by(|a, b| b.bytes.cmp(&a.bytes));
    StorageUsage {
        total_bytes: usage.total_bytes as i64,
        files: usage.files,
        dirs: usage.dirs,
        by_extension,
        children: usage
            .children
            .into_iter()
            .map(|(i, size)| item_of(&index.entries[i], size))
            .collect(),
    }
}

/// Carpetas que Android no deja leer a una app (SELinux) pero sí revisar una
/// por una: los nombres que suelen tener, para mostrar los que existen (como
/// los exploradores de los fabricantes).
fn known_children(path: &str) -> &'static [&'static str] {
    match path {
        "/" => &[
            "acct", "apex", "bin", "bugreports", "cache", "config", "d", "data",
            "data_mirror", "debug_ramdisk", "dev", "etc", "linkerconfig",
            "lost+found", "metadata", "mnt", "odm", "odm_dlkm", "oem",
            "postinstall", "proc", "product", "sdcard", "storage", "sys",
            "system", "system_dlkm", "system_ext", "vendor", "vendor_dlkm",
        ],
        "/storage" => &["emulated", "self"],
        "/storage/emulated" => &["0"],
        _ => &[],
    }
}

/// Nombres dentro de `path`. Si no se puede leer o sale vacía, los de
/// [known_children] que existen.
fn child_names(path: &str) -> Result<Vec<String>> {
    let read = fs::read_dir(path).map(|read| {
        read.flatten().map(|e| e.file_name().to_string_lossy().into_owned()).collect::<Vec<_>>()
    });
    let known = known_children(path);
    match read {
        Ok(names) if !names.is_empty() || known.is_empty() => Ok(names),
        Err(e) if known.is_empty() => Err(anyhow!("{e}")),
        _ => Ok(known
            .iter()
            .filter(|n| fs::symlink_metadata(Path::new(path).join(n)).is_ok())
            .map(|n| n.to_string())
            .collect()),
    }
}

/// Contenido de una carpeta por partes: primero las entradas (la primera
/// parte es chica para mostrar algo rápido) y después las carpetas otra vez
/// con `child_count`. Sin `show_hidden` omite los nombres con punto.
pub fn list_dir(path: String, show_hidden: bool, sink: StreamSink<Vec<FileItem>>) -> Result<()> {
    let visible = |name: &str| show_hidden || !name.starts_with('.');
    let names = child_names(&path)?;

    // Tamaños de carpeta del índice, si ya existe.
    let guard = INDEX.read().unwrap();
    let dir_sizes = guard.as_ref().map(|i| &i.dir_sizes);

    let mut batch_size = 64;
    let mut batch = Vec::new();
    let mut dirs = Vec::new();
    for name in names {
        // La papelera de Gakoken nunca se muestra, ni con los ocultos.
        if !visible(&name) || name == crate::ops::TRASH_DIR {
            continue;
        }
        let full = Path::new(&path).join(&name);
        // Sigue enlaces para saber si apuntan a una carpeta.
        let md = fs::metadata(&full).or_else(|_| fs::symlink_metadata(&full));
        let (is_dir, len, mtime) = match md {
            Ok(md) => (md.is_dir(), md.len(), index::mtime_secs(md.modified().ok())),
            Err(_) => (false, 0, 0),
        };
        let path = full.to_string_lossy().into_owned();
        let size = if is_dir { dir_sizes.and_then(|s| s.get(&path)).copied().unwrap_or(0) } else { len };
        let entry = FileItem { path, name, is_dir, size: size as i64, modified_secs: mtime, child_count: None };
        if is_dir {
            dirs.push(entry.clone());
        }
        batch.push(entry);
        if batch.len() >= batch_size {
            if sink.add(std::mem::take(&mut batch)).is_err() {
                return Ok(()); // La pantalla dejó de escuchar.
            }
            batch_size = 512;
        }
    }
    drop(guard);
    if !batch.is_empty() && sink.add(std::mem::take(&mut batch)).is_err() {
        return Ok(());
    }

    // Segunda parte: cuántos elementos tiene cada carpeta.
    for mut dir in dirs {
        dir.child_count = child_names(&dir.path)
            .ok()
            .map(|names| names.iter().filter(|n| visible(n)).count() as u32);
        batch.push(dir);
        if batch.len() >= 32 && sink.add(std::mem::take(&mut batch)).is_err() {
            return Ok(());
        }
    }
    if !batch.is_empty() {
        let _ = sink.add(batch);
    }
    Ok(())
}
