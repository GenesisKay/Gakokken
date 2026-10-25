/// Versión del motor; la usa la app para comprobar que Rust responde.
#[flutter_rust_bridge::frb(sync)]
pub fn core_version() -> String {
    format!("gakoken_core {}", env!("CARGO_PKG_VERSION"))
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
