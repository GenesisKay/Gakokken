//! Índice de archivos: recorrido en paralelo, copia en SQLite para abrir
//! rápido la siguiente vez, búsqueda y espacio usado sobre memoria.
//! Arquitectura: Vault/Morobu/Gakoken/Gakoken-Arquitectura.md

use std::collections::{HashMap, HashSet};
use std::path::{Path, MAIN_SEPARATOR};
use std::sync::RwLock;
use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::Result;
use jwalk::WalkDirGeneric;
use nucleo_matcher::pattern::{CaseMatching, Normalization, Pattern};
use nucleo_matcher::{Config, Matcher, Utf32Str};
use rayon::prelude::*;
use rusqlite::{params, Connection, OptionalExtension};

pub struct Entry {
    pub path: String,
    pub name: String,
    pub name_lower: String,
    pub size: u64,
    pub mtime: i64,
    pub is_dir: bool,
    /// El nombre o alguna carpeta de la ruta empieza con punto.
    pub hidden: bool,
}

pub struct Index {
    /// Carpetas raíz indexadas: el almacenamiento interno y las tarjetas SD.
    pub roots: Vec<String>,
    pub entries: Vec<Entry>,
    /// Tamaño de cada carpeta contando sus subcarpetas.
    pub dir_sizes: HashMap<String, u64>,
    /// Última vez que el índice se puso al día (completo o solo lo que cambió).
    pub indexed_at: i64,
    /// Último recorrido completo. Lo que solo cambia por dentro de un archivo
    /// (sin tocar su carpeta) se corrige en el siguiente.
    pub full_at: i64,
    /// Cuánto tardó la última puesta al día, en milisegundos. No se guarda.
    pub took_ms: u32,
}

/// Índice vigente. Se reemplaza entero al terminar un indexado, así las
/// búsquedas siguen funcionando con el anterior mientras tanto.
pub static INDEX: RwLock<Option<Index>> = RwLock::new(None);

/// Recorre `root` en paralelo sin seguir enlaces. Llama a `progress` cada
/// tanto con las entradas vistas. Devuelve las entradas y cuántas carpetas
/// no se pudieron leer.
pub fn walk(root: &Path, mut progress: impl FnMut(usize)) -> (Vec<Entry>, u64) {
    // El stat de cada hijo se hace en el mismo hilo que leyó la carpeta.
    let walker = WalkDirGeneric::<((), Option<(u64, i64)>)>::new(root)
        .skip_hidden(false)
        .follow_links(false)
        .process_read_dir(|_, _, _, children| {
            for child in children.iter_mut().flatten() {
                if let Ok(md) = child.metadata() {
                    child.client_state = Some((md.len(), mtime_secs(md.modified().ok())));
                }
            }
        });

    let root_len = root.to_string_lossy().len();
    let mut entries = Vec::new();
    let mut errors = 0;
    for item in walker {
        match item {
            Ok(e) if e.depth == 0 => {}
            Ok(e) => {
                let name = e.file_name.to_string_lossy().into_owned();
                let path = e.path().to_string_lossy().into_owned();
                let hidden = path[root_len..]
                    .split(MAIN_SEPARATOR)
                    .any(|part| part.starts_with('.'));
                let (size, mtime) = e.client_state.unwrap_or((0, 0));
                entries.push(Entry {
                    path,
                    name_lower: name.to_lowercase(),
                    name,
                    size,
                    mtime,
                    is_dir: e.file_type.is_dir(),
                    hidden,
                });
                if entries.len() % 2000 == 0 {
                    progress(entries.len());
                }
            }
            Err(_) => errors += 1,
        }
    }
    (entries, errors)
}

pub fn mtime_secs(time: Option<SystemTime>) -> i64 {
    time.and_then(|t| t.duration_since(UNIX_EPOCH).ok())
        .map_or(0, |d| d.as_secs() as i64)
}

pub fn now_secs() -> i64 {
    mtime_secs(Some(SystemTime::now()))
}

/// Suma el tamaño de cada archivo a todas sus carpetas, hasta `root`.
pub fn dir_sizes(root: &str, entries: &[Entry]) -> HashMap<String, u64> {
    dir_sizes_of(root, entries.iter())
}

fn dir_sizes_of<'a>(root: &str, entries: impl Iterator<Item = &'a Entry>) -> HashMap<String, u64> {
    let mut sizes: HashMap<String, u64> = HashMap::new();
    for e in entries.filter(|e| !e.is_dir) {
        let mut dir = Path::new(&e.path).parent();
        while let Some(d) = dir {
            let key = d.to_string_lossy();
            if key.len() <= root.len() {
                break;
            }
            *sizes.entry(key.into_owned()).or_default() += e.size;
            dir = d.parent();
        }
    }
    sizes
}

fn open_db(db_path: &str) -> Result<Connection> {
    let conn = Connection::open(db_path)?;
    conn.execute_batch(
        "PRAGMA journal_mode = WAL;
         PRAGMA synchronous = NORMAL;
         CREATE TABLE IF NOT EXISTS files (
             path   TEXT PRIMARY KEY,
             name   TEXT NOT NULL,
             size   INTEGER NOT NULL,
             mtime  INTEGER NOT NULL,
             is_dir INTEGER NOT NULL,
             hidden INTEGER NOT NULL
         );
         CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);",
    )?;
    Ok(conn)
}

/// Reemplaza el índice guardado en una sola transacción.
pub fn save(db_path: &str, index: &Index) -> Result<()> {
    let mut conn = open_db(db_path)?;
    let tx = conn.transaction()?;
    tx.execute("DELETE FROM files", [])?;
    {
        let mut stmt = tx.prepare("INSERT INTO files VALUES (?1, ?2, ?3, ?4, ?5, ?6)")?;
        for e in &index.entries {
            stmt.execute(params![e.path, e.name, e.size as i64, e.mtime, e.is_dir, e.hidden])?;
        }
    }
    let mut meta = tx.prepare("INSERT OR REPLACE INTO meta VALUES (?1, ?2)")?;
    meta.execute(params!["roots", index.roots.join("
")])?;
    meta.execute(params!["indexed_at", index.indexed_at.to_string()])?;
    meta.execute(params!["full_at", index.full_at.to_string()])?;
    drop(meta);
    tx.commit()?;
    Ok(())
}

/// Lee el índice guardado. None si nunca se indexaron exactamente `roots`
/// (por ejemplo, si se puso o se quitó una tarjeta SD).
pub fn load(db_path: &str, roots: &[String]) -> Result<Option<Index>> {
    let conn = open_db(db_path)?;
    let meta = |key: &str| -> Result<Option<String>> {
        Ok(conn
            .query_row("SELECT value FROM meta WHERE key = ?1", [key], |r| r.get(0))
            .optional()?)
    };
    if meta("roots")?.as_deref() != Some(roots.join("
").as_str()) {
        return Ok(None);
    }
    let indexed_at = meta("indexed_at")?.and_then(|v| v.parse().ok()).unwrap_or(0);
    let full_at = meta("full_at")?.and_then(|v| v.parse().ok()).unwrap_or(indexed_at);
    let mut stmt = conn.prepare("SELECT path, name, size, mtime, is_dir, hidden FROM files")?;
    let entries = stmt
        .query_map([], |r| {
            let name: String = r.get(1)?;
            Ok(Entry {
                path: r.get(0)?,
                name_lower: name.to_lowercase(),
                name,
                size: r.get::<_, i64>(2)? as u64,
                mtime: r.get(3)?,
                is_dir: r.get(4)?,
                hidden: r.get(5)?,
            })
        })?
        .collect::<rusqlite::Result<Vec<_>>>()?;
    let mut index = Index {
        roots: roots.to_vec(),
        entries,
        dir_sizes: HashMap::new(),
        indexed_at,
        full_at,
        took_ms: 0,
    };
    recompute_dir_sizes(&mut index);
    Ok(Some(index))
}

/// Guarda solo `paths` (y lo que tengan dentro) y las fechas de `dirs`, sin
/// reescribir todo el índice.
pub fn save_paths(db_path: &str, index: &Index, paths: &[String], dirs: &[String]) -> Result<()> {
    let mut conn = open_db(db_path)?;
    let tx = conn.transaction()?;
    {
        // Lo de dentro de una carpeta va de "carpeta/" a "carpeta0": '0' sigue a '/'.
        let next = char::from_u32(MAIN_SEPARATOR as u32 + 1).unwrap();
        let mut delete =
            tx.prepare("DELETE FROM files WHERE path = ?1 OR (path >= ?2 AND path < ?3)")?;
        for path in paths {
            let base = path.trim_end_matches(MAIN_SEPARATOR);
            delete.execute(params![path, format!("{base}{MAIN_SEPARATOR}"), format!("{base}{next}")])?;
        }
        let touched: HashSet<&str> = paths.iter().map(String::as_str).collect();
        let mut insert = tx.prepare("INSERT OR REPLACE INTO files VALUES (?1, ?2, ?3, ?4, ?5, ?6)")?;
        for e in index.entries.iter().filter(|e| under_any(&touched, &e.path)) {
            insert.execute(params![e.path, e.name, e.size as i64, e.mtime, e.is_dir, e.hidden])?;
        }
        let dates: HashMap<&str, i64> =
            index.entries.iter().filter(|e| e.is_dir).map(|e| (e.path.as_str(), e.mtime)).collect();
        let mut update = tx.prepare("UPDATE files SET mtime = ?2 WHERE path = ?1")?;
        for dir in dirs {
            if let Some(mtime) = dates.get(dir.as_str()) {
                update.execute(params![dir, mtime])?;
            }
        }
        let mut meta = tx.prepare("INSERT OR REPLACE INTO meta VALUES (?1, ?2)")?;
        meta.execute(params!["indexed_at", index.indexed_at.to_string()])?;
    }
    tx.commit()?;
    Ok(())
}

/// Si `path` está en `set` o dentro de alguna ruta de `set`.
fn under_any(set: &HashSet<&str>, path: &str) -> bool {
    let mut current = Some(Path::new(path));
    while let Some(p) = current {
        if set.contains(p.to_string_lossy().as_ref()) {
            return true;
        }
        current = p.parent();
    }
    false
}

/// Tamaños de carpeta de todas las raíces del índice.
fn recompute_dir_sizes(index: &mut Index) {
    let mut sizes = HashMap::new();
    for root in &index.roots {
        let prefix = format!("{}{MAIN_SEPARATOR}", root.trim_end_matches(MAIN_SEPARATOR));
        let mine = index.entries.iter().filter(|e| e.path.starts_with(&prefix));
        sizes.extend(dir_sizes_of(root, mine));
    }
    index.dir_sizes = sizes;
}

/// Pone al día solo `paths` (y lo que tengan dentro) después de copiar,
/// mover, renombrar o borrar, sin recorrer todo el almacenamiento.
pub fn refresh(index: &mut Index, paths: &[String]) {
    let touched: HashSet<&str> = paths.iter().map(String::as_str).collect();
    index.entries.retain(|e| !under_any(&touched, &e.path));
    for path in paths {
        let Some(root) = index.roots.iter().find(|r| is_within(r, path) && r.as_str() != path) else {
            continue;
        };
        let Ok(md) = std::fs::symlink_metadata(path) else { continue };
        let hidden = path[root.len()..].split(MAIN_SEPARATOR).any(|part| part.starts_with('.'));
        let name = Path::new(path).file_name().map(|n| n.to_string_lossy().into_owned()).unwrap_or_default();
        index.entries.push(Entry {
            path: path.clone(),
            name_lower: name.to_lowercase(),
            name,
            size: md.len(),
            mtime: mtime_secs(md.modified().ok()),
            is_dir: md.is_dir(),
            hidden,
        });
        if md.is_dir() {
            let (inner, _) = walk(Path::new(path), |_| {});
            index.entries.extend(inner.into_iter().map(|mut e| {
                e.hidden |= hidden;
                e
            }));
        }
    }
    recompute_dir_sizes(index);
}

/// Qué cambió desde el último indexado, mirando solo la fecha de cada
/// carpeta: crear, borrar o renombrar algo cambia la fecha de su carpeta.
pub struct Changes {
    /// Rutas que aparecieron, desaparecieron o cambiaron (para [`refresh`]).
    pub paths: Vec<String>,
    /// Carpetas que cambiaron, con su fecha nueva.
    pub dirs: Vec<(String, i64)>,
}

/// Busca los cambios sin recorrer todo: un `stat` por carpeta en paralelo y
/// solo se leen las carpetas cuya fecha cambió. Las raíces siempre se leen.
pub fn changes(index: &Index) -> Changes {
    let mut changed: Vec<(String, i64)> = index
        .entries
        .par_iter()
        .filter(|e| e.is_dir)
        .filter_map(|e| {
            let mtime = mtime_secs(std::fs::metadata(&e.path).ok()?.modified().ok());
            (mtime != e.mtime).then(|| (e.path.clone(), mtime))
        })
        .collect();
    let known: HashMap<&str, &Entry> = index.entries.iter().map(|e| (e.path.as_str(), e)).collect();
    let mut children: HashMap<&str, Vec<&str>> = HashMap::new();
    for e in &index.entries {
        if let Some(parent) = Path::new(&e.path).parent().and_then(|p| p.to_str()) {
            children.entry(parent).or_default().push(&e.path);
        }
    }
    let to_read: Vec<&str> = index
        .roots
        .iter()
        .map(String::as_str)
        .chain(changed.iter().map(|(p, _)| p.as_str()))
        .collect();

    let paths: Vec<String> = to_read
        .par_iter()
        .flat_map_iter(|&dir| {
            let mut out = Vec::new();
            let Ok(read) = std::fs::read_dir(dir) else { return out };
            let mut present = HashSet::new();
            for item in read.flatten() {
                let path = item.path().to_string_lossy().into_owned();
                let differs = match (known.get(path.as_str()), item.metadata()) {
                    (None, _) => true,
                    (Some(e), Ok(md)) => {
                        e.is_dir != md.is_dir()
                            || (!e.is_dir
                                && (e.size != md.len()
                                    || e.mtime != mtime_secs(md.modified().ok())))
                    }
                    (Some(_), Err(_)) => false,
                };
                if differs {
                    out.push(path.clone());
                }
                present.insert(path);
            }
            for &child in children.get(dir).map(Vec::as_slice).unwrap_or(&[]) {
                if !present.contains(child) {
                    out.push(child.to_string());
                }
            }
            out
        })
        .collect();
    changed.retain(|(p, _)| known.contains_key(p.as_str()));
    Changes { paths, dirs: changed }
}

/// Aplica lo que encontró [`changes`].
pub fn apply(index: &mut Index, changes: &Changes) {
    let dates: HashMap<&str, i64> = changes.dirs.iter().map(|(p, m)| (p.as_str(), *m)).collect();
    for e in index.entries.iter_mut().filter(|e| e.is_dir) {
        if let Some(&mtime) = dates.get(e.path.as_str()) {
            e.mtime = mtime;
        }
    }
    if !changes.paths.is_empty() {
        refresh(index, &changes.paths);
    }
}

/// Errores de escritura que tolera la búsqueda según el largo de la consulta.
fn typo_budget(len: usize) -> usize {
    match len {
        0..=3 => 0,
        4..=7 => 1,
        _ => 2,
    }
}

/// Menor distancia de edición (con letras cambiadas de lugar) entre `query`
/// y cualquier parte de `text`. Algoritmo de Sellers con transposiciones.
pub fn substring_distance(query: &[char], text: &[char]) -> usize {
    let m = query.len();
    if m == 0 {
        return 0;
    }
    // prev2, prev y cur son las filas i-2, i-1 e i, por columna de texto.
    let n = text.len();
    let mut prev2 = vec![0usize; n + 1];
    let mut prev: Vec<usize> = vec![0; n + 1];
    let mut cur = vec![0usize; n + 1];
    for i in 1..=m {
        cur[0] = i;
        for j in 1..=n {
            let cost = usize::from(query[i - 1] != text[j - 1]);
            let mut best = (prev[j - 1] + cost).min(prev[j] + 1).min(cur[j - 1] + 1);
            if i > 1 && j > 1 && query[i - 1] == text[j - 2] && query[i - 2] == text[j - 1] {
                best = best.min(prev2[j - 2] + 1);
            }
            cur[j] = best;
        }
        std::mem::swap(&mut prev2, &mut prev);
        std::mem::swap(&mut prev, &mut cur);
    }
    // Después del último swap, `prev` es la fila m. La fila 0 es toda ceros:
    // la coincidencia puede empezar en cualquier parte del nombre.
    *prev.iter().min().unwrap()
}

/// Busca por nombre. Orden: los que contienen la consulta tal cual (primero
/// los que empiezan con ella), luego coincidencias difusas (letras en orden
/// con huecos) y al final los que tienen errores de escritura.
pub fn search(
    index: &Index,
    query: &str,
    within: Option<&str>,
    include_hidden: bool,
    limit: usize,
) -> Vec<usize> {
    let query = query.trim();
    if query.is_empty() {
        return Vec::new();
    }
    let lower = query.to_lowercase();
    let lower_chars: Vec<char> = lower.chars().collect();
    let budget = typo_budget(lower_chars.len());
    let pattern = Pattern::parse(query, CaseMatching::Ignore, Normalization::Smart);
    let prefix = within.map(|w| format!("{}{}", w.trim_end_matches(MAIN_SEPARATOR), MAIN_SEPARATOR));
    let trash = format!("{MAIN_SEPARATOR}{}", crate::ops::TRASH_DIR);

    let mut hits: Vec<(u32, usize)> = index
        .entries
        .par_iter()
        .enumerate()
        .map_init(
            || (Matcher::new(Config::DEFAULT), Vec::new()),
            |(matcher, buf), (i, e)| {
                if (e.hidden && !include_hidden) || e.path.contains(&trash) {
                    return None;
                }
                if let Some(p) = &prefix {
                    if !e.path.starts_with(p.as_str()) {
                        return None;
                    }
                }
                // Puntajes por nivel: el nivel pesa más que el puntaje de nucleo.
                if let Some(pos) = e.name_lower.find(&lower) {
                    let tier = if pos == 0 { 3_000_000 } else { 2_000_000 };
                    return Some((tier - e.name.len().min(10_000) as u32, i));
                }
                if let Some(score) = pattern.score(Utf32Str::new(&e.name, buf), matcher) {
                    return Some((1_000_000 + score.min(999_999), i));
                }
                if budget > 0 {
                    let text: Vec<char> = e.name_lower.chars().collect();
                    let d = substring_distance(&lower_chars, &text);
                    if d <= budget {
                        return Some(((budget - d + 1) as u32 * 1000, i));
                    }
                }
                None
            },
        )
        .flatten()
        .collect();
    hits.par_sort_unstable_by(|a, b| b.0.cmp(&a.0).then(a.1.cmp(&b.1)));
    hits.truncate(limit);
    hits.into_iter().map(|(_, i)| i).collect()
}

pub struct Usage {
    pub total_bytes: u64,
    pub files: u32,
    pub dirs: u32,
    /// Extensión en minúsculas (vacía si no tiene): bytes y archivos.
    pub by_extension: HashMap<String, (u64, u32)>,
    /// Hijos directos de la carpeta con su tamaño (carpetas con subcarpetas).
    pub children: Vec<(usize, u64)>,
}

/// Extensión como la entiende la app: sin punto, en minúsculas; un nombre
/// que empieza con punto no tiene extensión.
pub fn extension_of(name_lower: &str) -> &str {
    match name_lower.rfind('.') {
        Some(dot) if dot > 0 && dot < name_lower.len() - 1 => &name_lower[dot + 1..],
        _ => "",
    }
}

/// Índice de una sola carpeta, sin guardar: para el espacio usado de lo que
/// no se indexa (memorias USB).
pub fn scan(root: &str) -> Index {
    let (entries, _) = walk(Path::new(root), |_| {});
    let dir_sizes = dir_sizes(root, &entries);
    let now = now_secs();
    Index { roots: vec![root.to_string()], entries, dir_sizes, indexed_at: now, full_at: now, took_ms: 0 }
}

/// Si `path` es `root` o está dentro.
pub fn is_within(root: &str, path: &str) -> bool {
    let root = root.trim_end_matches(MAIN_SEPARATOR);
    path == root || path.strip_prefix(root).is_some_and(|rest| rest.starts_with(MAIN_SEPARATOR))
}

/// Archivos dentro de `dir` (con subcarpetas e incluidos ocultos, como el
/// espacio usado) cuya extensión está en `extensions`, del más pesado al más
/// ligero. Devuelve hasta `limit` posiciones en `index.entries`.
pub fn files_with_extensions(
    index: &Index,
    dir: &str,
    extensions: &HashSet<String>,
    limit: usize,
) -> Vec<usize> {
    let prefix = format!("{}{MAIN_SEPARATOR}", dir.trim_end_matches(MAIN_SEPARATOR));
    let mut hits: Vec<usize> = index
        .entries
        .iter()
        .enumerate()
        .filter(|(_, e)| {
            !e.is_dir
                && e.path.starts_with(&prefix)
                && extensions.contains(extension_of(&e.name_lower))
        })
        .map(|(i, _)| i)
        .collect();
    hits.sort_unstable_by(|&a, &b| index.entries[b].size.cmp(&index.entries[a].size));
    hits.truncate(limit);
    hits
}

/// Espacio usado dentro de `dir`, incluidos ocultos: también ocupan lugar.
pub fn usage(index: &Index, dir: &str) -> Usage {
    let dir = dir.trim_end_matches(MAIN_SEPARATOR);
    let prefix = format!("{dir}{MAIN_SEPARATOR}");
    let mut usage = Usage {
        total_bytes: 0,
        files: 0,
        dirs: 0,
        by_extension: HashMap::new(),
        children: Vec::new(),
    };
    for (i, e) in index.entries.iter().enumerate() {
        let Some(rest) = e.path.strip_prefix(prefix.as_str()) else { continue };
        let direct = !rest.contains(MAIN_SEPARATOR);
        if e.is_dir {
            usage.dirs += 1;
            if direct {
                usage.children.push((i, index.dir_sizes.get(&e.path).copied().unwrap_or(0)));
            }
            continue;
        }
        usage.files += 1;
        usage.total_bytes += e.size;
        let slot = usage.by_extension.entry(extension_of(&e.name_lower).to_string()).or_default();
        slot.0 += e.size;
        slot.1 += 1;
        if direct {
            usage.children.push((i, e.size));
        }
    }
    usage.children.sort_unstable_by(|a, b| b.1.cmp(&a.1));
    usage
}

#[cfg(test)]
mod tests {
    use super::*;

    fn chars(s: &str) -> Vec<char> {
        s.chars().collect()
    }

    /// Carpeta de prueba: raíz/Fotos/{a.jpg, b.png}, raíz/WhatsApp/x.pdf,
    /// raíz/.oculta/whatsapp.txt, raíz/notas.txt
    fn sample() -> (tempdir::Dir, Index) {
        let dir = tempdir::Dir::new();
        let root = dir.path();
        fs_write(&root.join("Fotos/a.jpg"), 1000);
        fs_write(&root.join("Fotos/b.png"), 500);
        fs_write(&root.join("WhatsApp/x.pdf"), 200);
        fs_write(&root.join(".oculta/whatsapp.txt"), 50);
        fs_write(&root.join("notas.txt"), 10);
        let root_str = root.to_string_lossy().into_owned();
        let (entries, errors) = walk(root, |_| {});
        assert_eq!(errors, 0);
        let sizes = dir_sizes(&root_str, &entries);
        let index = Index {
            roots: vec![root_str],
            entries,
            dir_sizes: sizes,
            indexed_at: 1,
            full_at: 1,
            took_ms: 0,
        };
        (dir, index)
    }

    fn fs_write(path: &Path, bytes: usize) {
        std::fs::create_dir_all(path.parent().unwrap()).unwrap();
        std::fs::write(path, vec![b'x'; bytes]).unwrap();
    }

    fn names(index: &Index, hits: Vec<usize>) -> Vec<String> {
        hits.into_iter().map(|i| index.entries[i].name.clone()).collect()
    }

    #[test]
    fn typo_distance() {
        assert_eq!(substring_distance(&chars("whatsapp"), &chars("whatsapp images")), 0);
        assert_eq!(substring_distance(&chars("wahtsapp"), &chars("whatsapp")), 1);
        assert_eq!(substring_distance(&chars("scrennshot"), &chars("screenshot_2026.png")), 1);
        assert!(substring_distance(&chars("factura"), &chars("musica")) > 1);
    }

    #[test]
    fn search_ranks_and_tolerates_typos() {
        let (_dir, index) = sample();
        // Los ocultos no salen.
        assert_eq!(names(&index, search(&index, "whatsapp", None, false, 50)), vec!["WhatsApp"]);
        assert_eq!(names(&index, search(&index, "wahtsapp", None, false, 50)), vec!["WhatsApp"]);
        assert_eq!(names(&index, search(&index, "fotos", None, false, 50)), vec!["Fotos"]);
        assert!(search(&index, "   ", None, false, 50).is_empty());
        // Empieza con la consulta antes que la contiene.
        let hits = names(&index, search(&index, "a", None, false, 50));
        assert_eq!(hits[0], "a.jpg");
    }

    #[test]
    fn hidden_only_when_asked() {
        let (_dir, index) = sample();
        let hits = names(&index, search(&index, "whatsapp", None, true, 50));
        assert_eq!(hits.len(), 2);
        assert!(hits.contains(&"whatsapp.txt".to_string()));
    }

    #[test]
    fn scan_and_within() {
        let (_dir, index) = sample();
        let scanned = scan(&index.roots[0]);
        assert_eq!(scanned.entries.len(), index.entries.len());
        assert_eq!(usage(&scanned, &index.roots[0]).total_bytes, 1760);
        assert!(is_within("/a/b", "/a/b"));
        assert!(is_within("/a/b", &format!("/a/b{MAIN_SEPARATOR}c")));
        assert!(!is_within("/a/b", "/a/bc"));
    }

    #[test]
    fn search_within_a_folder() {
        let (_dir, index) = sample();
        let fotos = Path::new(&index.roots[0]).join("Fotos").to_string_lossy().into_owned();
        let hits = names(&index, search(&index, "pdf", Some(&fotos), false, 50));
        assert!(hits.is_empty());
        let hits = names(&index, search(&index, "jpg", Some(&fotos), false, 50));
        assert_eq!(hits, vec!["a.jpg"]);
    }

    #[test]
    fn usage_counts_subfolders_and_hidden() {
        let (_dir, index) = sample();
        let u = usage(&index, &index.roots[0]);
        assert_eq!(u.total_bytes, 1760);
        assert_eq!(u.files, 5);
        assert_eq!(u.dirs, 3);
        assert_eq!(u.by_extension["jpg"], (1000, 1));
        assert_eq!(u.by_extension["txt"], (60, 2));
        // Hijos directos, del más pesado al más ligero.
        let children: Vec<_> =
            u.children.iter().map(|(i, s)| (index.entries[*i].name.as_str(), *s)).collect();
        assert_eq!(children[0], ("Fotos", 1500));
        assert_eq!(children.last().unwrap(), &("notas.txt", 10));
    }

    #[test]
    fn save_and_load() {
        let (dir, index) = sample();
        let db = dir.path().join("index.db").to_string_lossy().into_owned();
        save(&db, &index).unwrap();
        let loaded = load(&db, &index.roots).unwrap().unwrap();
        assert_eq!(loaded.entries.len(), index.entries.len());
        assert_eq!(loaded.indexed_at, 1);
        assert_eq!(loaded.dir_sizes, index.dir_sizes);
        // Otra raíz no reutiliza el índice.
        assert!(load(&db, &["/otra".to_string()]).unwrap().is_none());
    }

    #[test]
    fn refresh_only_touched_paths() {
        let (dir, mut index) = sample();
        let root = index.roots[0].clone();
        let fotos = Path::new(&root).join("Fotos");
        std::fs::remove_file(fotos.join("b.png")).unwrap();
        fs_write(&fotos.join("nuevo/c.jpg"), 40);
        let trash = Path::new(&root).join(crate::ops::TRASH_DIR);
        fs_write(&trash.join("x"), 5);
        refresh(&mut index, &[
            fotos.join("b.png").to_string_lossy().into_owned(),
            fotos.join("nuevo").to_string_lossy().into_owned(),
            trash.to_string_lossy().into_owned(),
        ]);
        assert_eq!(index.dir_sizes[&fotos.to_string_lossy().into_owned()], 1040);
        assert!(names(&index, search(&index, "c.jpg", None, true, 50)).contains(&"c.jpg".to_string()));
        assert!(search(&index, "b.png", None, true, 50).is_empty());
        // La papelera ocupa espacio pero no sale en Buscar.
        assert!(search(&index, "x", None, true, 50).iter().all(|&i| index.entries[i].name != "x"));
        drop(dir);
    }

    #[test]
    fn changes_finds_only_what_changed() {
        let (dir, mut index) = sample();
        let root = index.roots[0].clone();
        assert!(changes(&index).paths.is_empty(), "Sin cambios no hay nada que leer");
        let fotos = Path::new(&root).join("Fotos");
        let fotos_str = fotos.to_string_lossy().into_owned();
        // La fecha de la carpeta va en segundos: se fuerza una distinta.
        for e in index.entries.iter_mut().filter(|e| e.path == fotos_str) {
            e.mtime -= 10;
        }
        std::fs::remove_file(fotos.join("a.jpg")).unwrap();
        fs_write(&fotos.join("nueva/d.jpg"), 7);
        fs_write(&Path::new(&root).join("raiz.txt"), 3);
        let found = changes(&index);
        let mut names: Vec<_> = found
            .paths
            .iter()
            .map(|p| Path::new(p).file_name().unwrap().to_string_lossy().into_owned())
            .collect();
        names.sort();
        assert_eq!(names, vec!["a.jpg", "nueva", "raiz.txt"]);
        apply(&mut index, &found);
        assert_eq!(index.dir_sizes[&fotos_str], 507);
        assert!(changes(&index).paths.is_empty(), "Ya quedó al día");

        // Guardar solo lo que cambió deja la misma copia que guardar todo.
        let db = dir.path().join("index.db").to_string_lossy().into_owned();
        save(&db, &index).unwrap();
        let nuevo = fotos.join("nueva").join("e.jpg").to_string_lossy().into_owned();
        fs_write(Path::new(&nuevo), 1);
        refresh(&mut index, &[nuevo.clone()]);
        save_paths(&db, &index, &[nuevo], &[]).unwrap();
        assert_eq!(load(&db, &index.roots).unwrap().unwrap().entries.len(), index.entries.len());
    }

    #[test]
    fn files_of_a_type_largest_first() {
        let (_dir, index) = sample();
        let images: HashSet<String> = ["jpg", "png"].iter().map(|s| s.to_string()).collect();
        let hits = names(&index, files_with_extensions(&index, &index.roots[0], &images, 50));
        assert_eq!(hits, vec!["a.jpg", "b.png"]);
        let txt: HashSet<String> = ["txt".to_string()].into();
        let hits = names(&index, files_with_extensions(&index, &index.roots[0], &txt, 1));
        assert_eq!(hits, vec!["whatsapp.txt"], "Incluye ocultos y respeta el límite");
    }

    #[test]
    fn extensions() {
        assert_eq!(extension_of("foto.jpg"), "jpg");
        assert_eq!(extension_of(".nomedia"), "");
        assert_eq!(extension_of("archivo."), "");
        assert_eq!(extension_of("respaldo.tar.gz"), "gz");
    }

    /// Carpeta temporal que se borra sola.
    mod tempdir {
        use std::path::{Path, PathBuf};
        use std::sync::atomic::{AtomicU32, Ordering};

        static NEXT: AtomicU32 = AtomicU32::new(0);

        pub struct Dir(PathBuf);

        impl Dir {
            pub fn new() -> Self {
                let n = NEXT.fetch_add(1, Ordering::Relaxed);
                let path = std::env::temp_dir()
                    .join(format!("gakoken_core_{}_{n}", std::process::id()));
                let _ = std::fs::remove_dir_all(&path);
                std::fs::create_dir_all(&path).unwrap();
                Dir(path)
            }

            pub fn path(&self) -> &Path {
                &self.0
            }
        }

        impl Drop for Dir {
            fn drop(&mut self) {
                let _ = std::fs::remove_dir_all(&self.0);
            }
        }
    }
}
