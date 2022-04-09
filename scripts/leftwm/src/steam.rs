use leftwm_core::{
    config::{InsertBehavior, Keybind, ScratchPad, Workspace},
    layouts::Layout,
    models::{FocusBehaviour, Gutter, LayoutMode, Margins, Size},
    Manager, State, Window, XlibDisplayServer,
};
use slog::{o, Drain};
use std::panic;

const MOD_KEY: &str = "Mod4";

/// General configuration
#[derive(Debug)]
pub struct Config;

impl leftwm_core::Config for Config {
    fn mapped_bindings(&self) -> Vec<Keybind> {
        use leftwm_core::Command;

        let commands = vec![
            Keybind {
                command: Command::Execute("dmenu_run".into()),
                modifier: vec![MOD_KEY.to_owned()],
                key: "space".to_owned(),
            },
            Keybind {
                command: Command::Execute("xterm".into()),
                modifier: vec![MOD_KEY.to_owned()],
                key: "Return".to_owned(),
            },
            Keybind {
                command: Command::CloseWindow,
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "c".to_owned(),
            },
            Keybind {
                command: Command::Execute("kill steam".into()),
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "q".to_owned(),
            },
            Keybind {
                command: Command::MoveWindowUp,
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "k".to_owned(),
            },
            Keybind {
                command: Command::MoveWindowDown,
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "j".to_owned(),
            },
            Keybind {
                command: Command::FocusWindowUp,
                modifier: vec![MOD_KEY.to_owned()],
                key: "k".to_owned(),
            },
            Keybind {
                command: Command::FocusWindowDown,
                modifier: vec![MOD_KEY.to_owned()],
                key: "j".to_owned(),
            },
            Keybind {
                command: Command::MoveWindowUp,
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "Up".to_owned(),
            },
            Keybind {
                command: Command::MoveWindowDown,
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "Down".to_owned(),
            },
            Keybind {
                command: Command::FocusWindowUp,
                modifier: vec![MOD_KEY.to_owned()],
                key: "Up".to_owned(),
            },
            Keybind {
                command: Command::FocusWindowDown,
                modifier: vec![MOD_KEY.to_owned()],
                key: "Down".to_owned(),
            },
        ];

        commands
    }

    fn create_list_of_tag_labels(&self) -> Vec<String> {
        vec!["1".to_string()]
    }

    fn workspaces(&self) -> Option<Vec<Workspace>> {
        Some(vec![])
    }

    fn focus_behaviour(&self) -> FocusBehaviour {
        FocusBehaviour::Sloppy
    }

    fn mousekey(&self) -> Vec<String> {
        vec![MOD_KEY.to_string()]
    }

    fn create_list_of_scratchpads(&self) -> Vec<ScratchPad> {
        Default::default()
    }

    fn layouts(&self) -> Vec<Layout> {
        vec![Layout::Monocle]
    }

    fn focus_new_windows(&self) -> bool {
        true
    }

    fn border_width(&self) -> i32 {
        0
    }

    fn margin(&self) -> Margins {
        Margins::new(0)
    }

    fn workspace_margin(&self) -> Option<Margins> {
        None
    }

    fn gutter(&self) -> Option<Vec<Gutter>> {
        None
    }

    fn default_border_color(&self) -> String {
        "#000000".into()
    }

    fn floating_border_color(&self) -> String {
        "#000000".into()
    }

    fn focused_border_color(&self) -> String {
        "#000000".into()
    }

    fn on_new_window_cmd(&self) -> Option<String> {
        None
    }

    fn get_list_of_gutters(&self) -> Vec<Gutter> {
        Default::default()
    }

    fn max_window_width(&self) -> Option<Size> {
        None
    }

    fn command_handler<SERVER>(_: &str, _: &mut Manager<Self, SERVER>) -> bool {
        false
    }

    fn always_float(&self) -> bool {
        false
    }

    fn default_width(&self) -> i32 {
        1000
    }

    fn default_height(&self) -> i32 {
        800
    }

    fn save_state(&self, _state: &State) {}

    fn load_state(&self, _state: &mut State) {}

    fn layout_mode(&self) -> LayoutMode {
        LayoutMode::Workspace
    }

    fn setup_predefined_window(&self, _window: &mut Window) -> bool {
        false
    }

    fn disable_tile_drag(&self) -> bool {
        true
    }

    fn insert_behavior(&self) -> InsertBehavior {
        Default::default()
    }

    /*
    fn pipe_file(&self) -> PathBuf {
        PathBuf::from("/tmp/leftwm.sock")
    }
    */
}

fn main() {
    let drain = slog_term::CompactFormat::new(slog_term::TermDecorator::new().stdout().build())
        .build()
        .ignore_res();

    // Set level filters from RUST_LOG. Defaults to `info`.
    let envlogger = slog_envlogger::LogBuilder::new(drain)
        .parse(&std::env::var("RUST_LOG").unwrap_or_else(|_| "info".into()))
        .build()
        .ignore_res();

    let logger = slog::Logger::root(slog_async::Async::default(envlogger).ignore_res(), o!());

    slog_stdlog::init().unwrap_or_else(|err| {
        eprintln!("failed to setup logging: {}", err);
    });

    let _guard = slog_scope::set_global_logger(logger);

    log::info!("leftwm-worker booted!");

    let completed = panic::catch_unwind(|| {
        let rt = tokio::runtime::Runtime::new().expect("ERROR: couldn't init Tokio runtime");
        let _rt_guard = rt.enter();

        let config = Config;

        let manager = Manager::<Config, XlibDisplayServer>::new(config);
        manager.register_child_hook();

        rt.block_on(manager.event_loop());
    });

    match completed {
        Ok(_) => log::info!("Completed"),
        Err(err) => log::error!("Completed with error: {:?}", err),
    }
}
