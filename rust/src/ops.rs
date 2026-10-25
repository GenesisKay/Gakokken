//! Operaciones con archivos: copiar, mover, renombrar y borrar. Copiar y
//! mover corren como tareas con progreso y se pueden cancelar sin dejar
//! archivos a medias.

use std::collections::HashMap;
use std::fs::{self, File};
use std::io::{Read, Write};
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

use anyhow::{anyhow, bail, Result};

/// Carpeta de la papelera de Gakoken en la raíz de cada memoria. Nunca se
/// muestra en Explorar ni sale en Buscar.
pub const TRASH_DIR: &str = ".gakoken-trash";

/// Qué hacer si en el destino ya hay algo con el mismo nombre.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Conflict {
    Replace,
    KeepBoth,
    Skip,
}

#[derive(Default, Clone)]
pub struct Progress {
    pub done_bytes: u64,
    pub total_bytes: u64,
    pub done_items: u32,
    pub total_items: u32,
    pub current: String,
}

pub struct Report {
    pub cancelled: bool,
    /// Nombres de lo que no se pudo copiar o mover.
    pub failed: Vec<String>,
    /// Rutas finales de lo que sí quedó en el destino.
    pub created: Vec<String>,
}

/// Banderas de cancelación por tarea.
static JOBS: Mutex<Option<HashMap<u32, Arc<AtomicBool>>>> = Mutex::new(None);

pub fn register(job: u32) -> Arc<AtomicBool> {
    let flag = Arc::new(AtomicBool::new(false));
    JOBS.lock().unwrap().get_or_insert_with(HashMap::new).insert(job, flag.clone());
    flag
}

pub fn unregister(job: u32) {
    if let Some(jobs) = JOBS.lock().unwrap().as_mut() {
        jobs.remove(&job);
    }
}

pub fn cancel(job: u32) {
    if let Some(flag) = JOBS.lock().unwrap().as_ref().and_then(|j| j.get(&job)) {
        flag.store(true, Ordering::Relaxed);
    }
}

/// `foto.jpg` -> (`foto`, `.jpg`). Las carpetas y los nombres con punto al
/// inicio no tienen extensión.
fn split_name(name: &str, is_dir: bool) -> (&str, &str) {
    if is_dir {
        return (name, "");
    }
    match name.rfind('.') {
        Some(dot) if dot > 0 => (&name[..dot], &name[dot..]),
        _ => (name, ""),
    }
}

/// Primera ruta libre: `foto.jpg`, `foto (1).jpg`, `foto (2).jpg`...
pub fn unique_path(path: &Path) -> PathBuf {
    if fs::symlink_metadata(path).is_err() {
        return path.to_path_buf();
    }
    let parent = path.parent().unwrap_or(Path::new(""));
    let name = path.file_name().map(|n| n.to_string_lossy().into_owned()).unwrap_or_default();
    let (stem, ext) = split_name(&name, path.is_dir());
    (1..)
        .map(|n| parent.join(format!("{stem} ({n}){ext}")))
        .find(|p| fs::symlink_metadata(p).is_err())
        .unwrap()
}

/// Nombres de `sources` que ya existen en `dest`.
pub fn conflicts(sources: &[String], dest: &Path) -> Vec<String> {
    sources
        .iter()
        .filter_map(|s| Path::new(s).file_name())
        .filter(|name| fs::symlink_metadata(dest.join(name)).is_ok())
        .map(|name| name.to_string_lossy().into_owned())
        .collect()
}

fn size_of(path: &Path) -> u64 {
    match fs::symlink_metadata(path) {
        Ok(md) if md.is_dir() => fs::read_dir(path)
            .map(|read| read.flatten().map(|e| size_of(&e.path())).sum())
            .unwrap_or(0),
        Ok(md) => md.len(),
        Err(_) => 0,
    }
}

struct Run<'a> {
    cancel: &'a AtomicBool,
    progress: Progress,
    last_report: Instant,
    report: &'a mut dyn FnMut(&Progress),
}

impl Run<'_> {
    fn tick(&mut self, force: bool) {
        if force || self.last_report.elapsed() >= Duration::from_millis(100) {
            (self.report)(&self.progress);
            self.last_report = Instant::now();
        }
    }

    fn cancelled(&self) -> bool {
        self.cancel.load(Ordering::Relaxed)
    }

    /// Copia un archivo por partes. Si se cancela, borra lo copiado.
    fn copy_file(&mut self, from: &Path, to: &Path) -> Result<()> {
        let mut input = File::open(from)?;
        let mut output = File::create(to)?;
        let mut buf = vec![0u8; 1 << 20];
        loop {
            if self.cancelled() {
                drop(output);
                let _ = fs::remove_file(to);
                bail!(Cancelled);
            }
            let n = input.read(&mut buf)?;
            if n == 0 {
                break;
            }
            output.write_all(&buf[..n])?;
            self.progress.done_bytes += n as u64;
            self.tick(false);
        }
        if let Ok(modified) = fs::metadata(from).and_then(|m| m.modified()) {
            let _ = output.set_modified(modified);
        }
        Ok(())
    }

    fn copy_tree(&mut self, from: &Path, to: &Path) -> Result<()> {
        let md = fs::symlink_metadata(from)?;
        if !md.is_dir() {
            return self.copy_file(from, to);
        }
        fs::create_dir_all(to)?;
        for entry in fs::read_dir(from)? {
            let entry = entry?;
            self.copy_tree(&entry.path(), &to.join(entry.file_name()))?;
        }
        Ok(())
    }
}

#[derive(Debug)]
struct Cancelled;

impl std::fmt::Display for Cancelled {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("cancelled")
    }
}

impl std::error::Error for Cancelled {}

/// Copia o mueve `sources` dentro de `dest`. Mover dentro de la misma memoria
/// es un renombrado (instantáneo); entre memorias se copia y luego se borra
/// el original. Al cancelar, el archivo a medias se borra y el original de lo
/// que se estaba moviendo queda intacto.
pub fn transfer(
    sources: &[String],
    dest: &Path,
    is_move: bool,
    conflict: Conflict,
    cancel: &AtomicBool,
    report: &mut dyn FnMut(&Progress),
) -> Result<Report> {
    let total_bytes = sources.iter().map(|s| size_of(Path::new(s))).sum();
    let mut run = Run {
        cancel,
        progress: Progress {
            total_bytes,
            total_items: sources.len() as u32,
            ..Default::default()
        },
        last_report: Instant::now(),
        report,
    };
    let mut out = Report { cancelled: false, failed: Vec::new(), created: Vec::new() };

    for source in sources {
        let from = Path::new(source);
        let name = from.file_name().map(|n| n.to_string_lossy().into_owned()).unwrap_or_default();
        run.progress.current = name.clone();
        run.tick(true);
        let item_bytes = size_of(from);
        let bytes_before = run.progress.done_bytes;

        let result = (|| -> Result<Option<PathBuf>> {
            if dest.starts_with(from) {
                bail!("no se puede copiar una carpeta dentro de sí misma");
            }
            let mut to = dest.join(&name);
            if fs::symlink_metadata(&to).is_ok() {
                if to == from {
                    // Pegar en la misma carpeta: al copiar, una copia nueva.
                    if is_move || conflict == Conflict::Skip {
                        return Ok(None);
                    }
                    to = unique_path(&to);
                } else {
                    match conflict {
                        Conflict::Skip => return Ok(None),
                        Conflict::KeepBoth => to = unique_path(&to),
                        Conflict::Replace => remove(&to)?,
                    }
                }
            }
            if is_move && fs::rename(from, &to).is_ok() {
                run.progress.done_bytes += item_bytes;
                return Ok(Some(to));
            }
            if let Err(e) = run.copy_tree(from, &to) {
                if e.is::<Cancelled>() {
                    // Una carpeta copiada a medias tampoco se deja.
                    if fs::symlink_metadata(from).map(|m| m.is_dir()).unwrap_or(false) {
                        let _ = fs::remove_dir_all(&to);
                    }
                }
                return Err(e);
            }
            if is_move {
                remove(from)?;
            }
            Ok(Some(to))
        })();

        match result {
            Ok(Some(to)) => out.created.push(to.to_string_lossy().into_owned()),
            Ok(None) => {}
            Err(e) if e.is::<Cancelled>() => {
                out.cancelled = true;
                return Ok(out);
            }
            Err(_) => out.failed.push(name),
        }
        // Lo omitido o fallido también cuenta para que la barra llegue al final.
        run.progress.done_bytes = bytes_before + item_bytes;
        run.progress.done_items += 1;
        run.tick(true);
    }
    Ok(out)
}

/// Borra para siempre un archivo o una carpeta con todo su contenido.
pub fn remove(path: &Path) -> Result<()> {
    let md = fs::symlink_metadata(path)?;
    if md.is_dir() {
        fs::remove_dir_all(path)?;
    } else {
        fs::remove_file(path)?;
    }
    Ok(())
}

/// Un nombre de archivo o carpeta sin rutas ni `.` y `..`.
fn valid_name(name: &str) -> bool {
    !(name.is_empty() || name == "." || name == ".." || name.contains(['/', '\\']))
}

/// Cambia el nombre. Devuelve la ruta nueva.
pub fn rename(path: &Path, new_name: &str) -> Result<PathBuf> {
    let new_name = new_name.trim();
    if !valid_name(new_name) {
        bail!("nombre no válido");
    }
    let to = path.parent().ok_or_else(|| anyhow!("sin carpeta"))?.join(new_name);
    if to == path {
        return Ok(to);
    }
    // En sistemas que no distinguen mayúsculas, "a" y "A" son el mismo archivo.
    let same_file = to.to_string_lossy().to_lowercase() == path.to_string_lossy().to_lowercase();
    if !same_file && fs::symlink_metadata(&to).is_ok() {
        bail!("ya existe");
    }
    fs::rename(path, &to)?;
    Ok(to)
}

/// Resultado de crear una carpeta.
#[derive(Debug, PartialEq, Eq)]
pub enum NewFolder {
    Created,
    /// Vacío, `.`, `..`, con `/` o el nombre de la papelera.
    Invalid,
    Exists,
    /// La carpeta de arriba no deja escribir (por ejemplo `/` en Android).
    Denied,
    Failed,
}

/// Crea la carpeta `name` dentro de `parent`.
pub fn create_folder(parent: &Path, name: &str) -> NewFolder {
    let name = name.trim();
    if !valid_name(name) || name == TRASH_DIR {
        return NewFolder::Invalid;
    }
    let path = parent.join(name);
    if fs::symlink_metadata(&path).is_ok() {
        return NewFolder::Exists;
    }
    match fs::create_dir(&path) {
        Ok(()) => NewFolder::Created,
        Err(e) if e.kind() == std::io::ErrorKind::AlreadyExists => NewFolder::Exists,
        Err(e) if e.kind() == std::io::ErrorKind::PermissionDenied => NewFolder::Denied,
        // Android a veces da "sistema de archivos de solo lectura" en vez de
        // permiso denegado.
        Err(e) if e.raw_os_error() == Some(30) => NewFolder::Denied,
        Err(_) => NewFolder::Failed,
    }
}

/// Mueve una sola ruta a otra exacta (papelera y restaurar). Crea la carpeta
/// de destino; entre memorias copia y borra.
pub fn move_exact(from: &Path, to: &Path) -> Result<()> {
    if let Some(parent) = to.parent() {
        fs::create_dir_all(parent)?;
    }
    if fs::rename(from, to).is_ok() {
        return Ok(());
    }
    let never = AtomicBool::new(false);
    let dest = to.parent().ok_or_else(|| anyhow!("sin carpeta"))?;
    let report = transfer(&[from.to_string_lossy().into_owned()], dest, true, Conflict::KeepBoth, &never, &mut |_| {})?;
    match report.created.first() {
        Some(created) if Path::new(created) != to => fs::rename(created, to)?,
        Some(_) => {}
        None => bail!("no se pudo mover"),
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn temp(name: &str) -> PathBuf {
        let dir = std::env::temp_dir().join(format!("gakoken_ops_{}_{name}", std::process::id()));
        let _ = fs::remove_dir_all(&dir);
        fs::create_dir_all(&dir).unwrap();
        dir
    }

    fn write(path: &Path, bytes: usize) {
        fs::create_dir_all(path.parent().unwrap()).unwrap();
        fs::write(path, vec![b'x'; bytes]).unwrap();
    }

    fn run(sources: &[&Path], dest: &Path, is_move: bool, conflict: Conflict) -> Report {
        let sources: Vec<String> = sources.iter().map(|s| s.to_string_lossy().into_owned()).collect();
        transfer(&sources, dest, is_move, conflict, &AtomicBool::new(false), &mut |_| {}).unwrap()
    }

    #[test]
    fn unique_names() {
        let dir = temp("unique");
        write(&dir.join("foto.jpg"), 1);
        write(&dir.join("foto (1).jpg"), 1);
        assert_eq!(unique_path(&dir.join("foto.jpg")), dir.join("foto (2).jpg"));
        assert_eq!(unique_path(&dir.join("nuevo.txt")), dir.join("nuevo.txt"));
        fs::create_dir_all(dir.join("Fotos.2026")).unwrap();
        assert_eq!(unique_path(&dir.join("Fotos.2026")), dir.join("Fotos.2026 (1)"));
        let _ = fs::remove_dir_all(dir);
    }

    #[test]
    fn copy_folder_and_conflicts() {
        let dir = temp("copy");
        let src = dir.join("src");
        write(&src.join("Album/a.jpg"), 300);
        write(&src.join("Album/sub/b.jpg"), 200);
        write(&src.join("nota.txt"), 10);
        let dest = dir.join("dest");
        write(&dest.join("nota.txt"), 1);

        let report = run(&[&src.join("Album"), &src.join("nota.txt")], &dest, false, Conflict::KeepBoth);
        assert!(report.failed.is_empty());
        assert_eq!(fs::read(dest.join("Album/sub/b.jpg")).unwrap().len(), 200);
        assert_eq!(fs::read(dest.join("nota (1).txt")).unwrap().len(), 10);
        assert_eq!(fs::read(dest.join("nota.txt")).unwrap().len(), 1);
        assert_eq!(conflicts(&[src.join("nota.txt").to_string_lossy().into_owned()], &dest), vec!["nota.txt"]);

        run(&[&src.join("nota.txt")], &dest, false, Conflict::Replace);
        assert_eq!(fs::read(dest.join("nota.txt")).unwrap().len(), 10);

        // Pegar en la misma carpeta crea una copia.
        run(&[&src.join("nota.txt")], &src, false, Conflict::Skip);
        assert!(!src.join("nota (1).txt").exists());
        run(&[&src.join("nota.txt")], &src, false, Conflict::KeepBoth);
        assert!(src.join("nota (1).txt").exists());

        // Una carpeta dentro de sí misma falla sin romper nada.
        let report = run(&[&src.join("Album")], &src.join("Album/sub"), false, Conflict::KeepBoth);
        assert_eq!(report.failed, vec!["Album"]);
        let _ = fs::remove_dir_all(dir);
    }

    #[test]
    fn move_and_cancel() {
        let dir = temp("move");
        write(&dir.join("a/grande.bin"), 3 << 20);
        let dest = dir.join("b");
        fs::create_dir_all(&dest).unwrap();

        // Cancelada desde el inicio: no queda nada a medias y el original sigue.
        let cancel = AtomicBool::new(true);
        let src = [dir.join("a/grande.bin").to_string_lossy().into_owned()];
        let report = transfer(&src, &dest, false, Conflict::KeepBoth, &cancel, &mut |_| {}).unwrap();
        assert!(report.cancelled);
        assert!(!dest.join("grande.bin").exists());
        assert!(dir.join("a/grande.bin").exists());

        let report = run(&[&dir.join("a/grande.bin")], &dest, true, Conflict::KeepBoth);
        assert_eq!(report.created.len(), 1);
        assert!(!dir.join("a/grande.bin").exists());
        assert_eq!(fs::metadata(dest.join("grande.bin")).unwrap().len(), 3 << 20);
        let _ = fs::remove_dir_all(dir);
    }

    #[test]
    fn rename_and_move_exact() {
        let dir = temp("rename");
        write(&dir.join("viejo.txt"), 5);
        write(&dir.join("otro.txt"), 5);
        assert!(rename(&dir.join("viejo.txt"), "otro.txt").is_err());
        assert!(rename(&dir.join("viejo.txt"), "a/b").is_err());
        let new = rename(&dir.join("viejo.txt"), "nuevo.txt").unwrap();
        assert_eq!(new, dir.join("nuevo.txt"));

        let trashed = dir.join(TRASH_DIR).join("123");
        move_exact(&new, &trashed).unwrap();
        assert!(trashed.exists() && !new.exists());
        move_exact(&trashed, &new).unwrap();
        assert!(new.exists());
        remove(&dir.join(TRASH_DIR)).unwrap();
        let _ = fs::remove_dir_all(dir);
    }

    #[test]
    fn new_folders() {
        let dir = temp("newfolder");
        assert_eq!(create_folder(&dir, " Fotos "), NewFolder::Created);
        assert!(dir.join("Fotos").is_dir());
        assert_eq!(create_folder(&dir, "Fotos"), NewFolder::Exists);
        write(&dir.join("nota.txt"), 1);
        assert_eq!(create_folder(&dir, "nota.txt"), NewFolder::Exists);
        for bad in ["", "  ", ".", "..", "a/b", TRASH_DIR] {
            assert_eq!(create_folder(&dir, bad), NewFolder::Invalid, "{bad}");
        }
        assert_eq!(create_folder(&dir.join("no-existe"), "x"), NewFolder::Failed);
        let _ = fs::remove_dir_all(dir);
    }
}
