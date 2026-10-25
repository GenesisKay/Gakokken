//! API de operaciones con archivos para la app: copiar y mover como tareas
//! con progreso, renombrar, papelera y borrar, y poner el índice al día.

use std::path::Path;

use anyhow::Result;

use crate::api::engine::IndexInfo;
use crate::frb_generated::StreamSink;
use crate::index::{self, INDEX};
use crate::ops::{self, Conflict};

/// Qué hacer si en el destino ya hay algo con el mismo nombre.
pub enum ConflictPolicy {
    Replace,
    KeepBoth,
    Skip,
}

pub struct JobProgress {
    pub done_bytes: i64,
    pub total_bytes: i64,
    pub done_items: u32,
    pub total_items: u32,
    /// Nombre de lo que se está copiando.
    pub current: String,
    pub finished: bool,
    pub cancelled: bool,
    /// Nombres de lo que no se pudo copiar o mover.
    pub failed: Vec<String>,
    /// Rutas finales de lo copiado o movido.
    pub created: Vec<String>,
}

/// Nombres de `sources` que ya existen en `dest_dir`, para preguntar antes.
pub fn find_conflicts(sources: Vec<String>, dest_dir: String) -> Vec<String> {
    ops::conflicts(&sources, Path::new(&dest_dir))
}

/// Copia o mueve `sources` dentro de `dest_dir`. Avisa el progreso unas diez
/// veces por segundo; `cancel_job(job_id)` la detiene sin dejar archivos a
/// medias.
pub fn transfer(
    job_id: u32,
    sources: Vec<String>,
    dest_dir: String,
    is_move: bool,
    conflict: ConflictPolicy,
    sink: StreamSink<JobProgress>,
) -> Result<()> {
    let cancel = ops::register(job_id);
    let conflict = match conflict {
        ConflictPolicy::Replace => Conflict::Replace,
        ConflictPolicy::KeepBoth => Conflict::KeepBoth,
        ConflictPolicy::Skip => Conflict::Skip,
    };
    let mut last = ops::Progress::default();
    let result = ops::transfer(&sources, Path::new(&dest_dir), is_move, conflict, &cancel, &mut |p| {
        last = p.clone();
        let _ = sink.add(progress_of(p, false, false, Vec::new(), Vec::new()));
    });
    ops::unregister(job_id);
    let report = result?;
    let _ = sink.add(progress_of(&last, true, report.cancelled, report.failed, report.created));
    Ok(())
}

fn progress_of(
    p: &ops::Progress,
    finished: bool,
    cancelled: bool,
    failed: Vec<String>,
    created: Vec<String>,
) -> JobProgress {
    JobProgress {
        done_bytes: p.done_bytes as i64,
        total_bytes: p.total_bytes as i64,
        done_items: p.done_items,
        total_items: p.total_items,
        current: p.current.clone(),
        finished,
        cancelled,
        failed,
        created,
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn cancel_job(job_id: u32) {
    ops::cancel(job_id);
}

/// Cambia el nombre; devuelve la ruta nueva. Falla si el nombre no es válido
/// o ya existe.
pub fn rename_path(path: String, new_name: String) -> Result<String> {
    Ok(ops::rename(Path::new(&path), &new_name)?.to_string_lossy().into_owned())
}

/// Resultado de crear una carpeta.
pub enum NewFolderStatus {
    Created,
    Invalid,
    Exists,
    Denied,
    Failed,
}

/// Crea la carpeta `name` dentro de `parent_dir`.
pub fn create_folder(parent_dir: String, name: String) -> NewFolderStatus {
    match ops::create_folder(Path::new(&parent_dir), &name) {
        ops::NewFolder::Created => NewFolderStatus::Created,
        ops::NewFolder::Invalid => NewFolderStatus::Invalid,
        ops::NewFolder::Exists => NewFolderStatus::Exists,
        ops::NewFolder::Denied => NewFolderStatus::Denied,
        ops::NewFolder::Failed => NewFolderStatus::Failed,
    }
}

/// Mueve una ruta a otra exacta (papelera y restaurar).
pub fn move_exact(from: String, to: String) -> Result<()> {
    ops::move_exact(Path::new(&from), Path::new(&to))
}

/// Primera ruta libre parecida a `path`: `foto (1).jpg` si `foto.jpg` existe.
#[flutter_rust_bridge::frb(sync)]
pub fn unique_path(path: String) -> String {
    ops::unique_path(Path::new(&path)).to_string_lossy().into_owned()
}

/// Borra para siempre. Devuelve los nombres que no se pudieron borrar.
pub fn delete_paths(paths: Vec<String>) -> Vec<String> {
    paths
        .into_iter()
        .filter(|p| ops::remove(Path::new(p)).is_err())
        .collect()
}

/// Nombre de la carpeta de la papelera en la raíz de cada memoria.
#[flutter_rust_bridge::frb(sync)]
pub fn trash_dir_name() -> String {
    ops::TRASH_DIR.to_string()
}

/// Pone al día en el índice solo `paths` (lo que se creó, movió o borró) y
/// lo guarda. Sin índice no hace nada.
pub fn index_refresh(db_path: String, paths: Vec<String>) -> Result<Option<IndexInfo>> {
    let mut guard = INDEX.write().unwrap();
    let Some(index) = guard.as_mut() else { return Ok(None) };
    index::refresh(index, &paths);
    index::save_paths(&db_path, index, &paths, &[])?;
    Ok(Some(super::engine::info_of(index)))
}
