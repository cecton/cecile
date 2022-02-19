use leftwm_core::{
    config::{Keybind, ScratchPad, Workspace},
    layouts::Layout,
    models::{FocusBehaviour, Gutter, LayoutMode, Margins, Size},
    Command, DisplayServer, Manager, State, Window, XlibDisplayServer,
};
use slog::{o, Drain};
use std::panic;

const MOD_KEY: &str = "Mod4";
const WORKSPACES_NUM: usize = 10;
const _: () = assert!(WORKSPACES_NUM <= 10);

/// General configuration
#[derive(Debug)]
pub struct Config;

impl leftwm_core::Config for Config {
    fn mapped_bindings(&self) -> Vec<Keybind> {
        let mut commands = vec![
            // Programs
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
            /*
            // NOTE: not working for now... seems to be trying to load theme
            Keybind {
                command: Command::SoftReload,
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "l".to_owned(),
            },
            */
            // hard reload
            Keybind {
                command: Command::Execute("kill $PPID".into()),
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "r".to_owned(),
            },
            // Quit session
            Keybind {
                command: Command::Execute("pkill leftwm-session".into()),
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "q".to_owned(),
            },
            // Window actions
            Keybind {
                command: Command::CloseWindow,
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "c".to_owned(),
            },
            Keybind {
                command: Command::ToggleFullScreen,
                modifier: vec![MOD_KEY.to_owned()],
                key: "f".to_owned(),
            },
            Keybind {
                command: Command::ToggleFloating,
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "space".to_owned(),
            },
            // Move windows
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
                command: Command::MoveWindowTop { swap: false },
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "Left".to_owned(),
            },
            // TODO implement MoveWindowRight?
            Keybind {
                command: Command::MoveWindowDown,
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: "Right".to_owned(),
            },
            // Window focus change
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
                command: Command::FocusWindowTop { swap: false },
                modifier: vec![MOD_KEY.to_owned()],
                key: "Left".to_owned(),
            },
            // TODO implement FocusWindowRight?
            Keybind {
                command: Command::FocusWindowDown,
                modifier: vec![MOD_KEY.to_owned()],
                key: "Right".to_owned(),
            },
            // Scratch pads
            Keybind {
                command: Command::ToggleScratchPad("terminal".to_string()),
                modifier: vec![MOD_KEY.to_owned()],
                key: "grave".to_owned(),
            },
        ];

        // add "goto workspace"
        for i in 1..=WORKSPACES_NUM {
            commands.push(Keybind {
                command: Command::GoToTag {
                    swap: false,
                    tag: i,
                },
                modifier: vec![MOD_KEY.to_owned()],
                key: (i % 10).to_string(),
            });
        }

        // and "move to workspace"
        for i in 1..=WORKSPACES_NUM {
            commands.push(Keybind {
                command: Command::SendWindowToTag {
                    window: None,
                    tag: i,
                },
                modifier: vec![MOD_KEY.to_owned(), "Shift".to_owned()],
                key: (i % 10).to_string(),
            });
        }

        if WORKSPACES_NUM > 1 {
            // NOTE it is not really obvious that SwapScreens is also for SwapTags
            commands.push(Keybind {
                command: Command::SwapScreens,
                modifier: vec![MOD_KEY.to_owned()],
                key: "Tab".to_string(),
            });
        }

        commands
    }

    fn create_list_of_tag_labels(&self) -> Vec<String> {
        (1..=WORKSPACES_NUM).map(|i| i.to_string()).collect()
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
        vec![ScratchPad {
            name: "terminal".to_string(),
            value: "xterm".to_string(),
            x: Some(Size::Pixel(0)),
            y: Some(Size::Pixel(0)),
            // NOTE: not per-cent! it's a ratio (per 1)
            width: Some(Size::Ratio(1.0)),
            height: Some(Size::Ratio(0.5)),
        }]
    }

    fn layouts(&self) -> Vec<Layout> {
        vec![Layout::MainAndVertStack, Layout::Monocle]
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

    fn command_handler<SERVER>(_command: &str, _manager: &mut Manager<Self, SERVER>) -> bool
    where
        SERVER: DisplayServer,
    {
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

    fn setup_predefined_window(&self, window: &mut Window) -> bool {
        match window.res_class.as_deref() {
            // TODO there are multiple classes per window. It seems only the last one is taken into
            //      account... this should be fixed
            /*
            Some("XTerm") => {
                window.set_floating(true);
                true
            }
            */
            _ => false,
        }
    }

    fn disable_tile_drag(&self) -> bool {
        true
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
