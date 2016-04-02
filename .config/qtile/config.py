from libqtile import layout, hook
from libqtile.command import lazy
from libqtile.config import Key, Group, Drag, Click

mod = "mod4"

floating_windows = """
    Gimp Dia Inkscape MPlayer mpv ffplay libreoffice-calc libreoffice-writer
    mednafen VirtualBox
    """.split()

default_windows_group = {
    "Iceweasel": "7",
    "Chromium": "4",
    "Firefox": "6",
    "Gajim": "3",
}

keys = [

    # Change active window
    Key(
        [mod], "Left",
        lazy.layout.left()
    ),
    Key(
        [mod], "Right",
        lazy.layout.right()
    ),
    Key(
        [mod], "Down",
        lazy.layout.down()
    ),
    Key(
        [mod], "Up",
        lazy.layout.up()
    ),

    # Move active window
    Key(
        [mod, "shift"], "Left",
        lazy.layout.shuffle_left()
    ),
    Key(
        [mod, "shift"], "Right",
        lazy.layout.shuffle_right()
    ),
    Key(
        [mod, "shift"], "Down",
        lazy.layout.shuffle_down()
    ),
    Key(
        [mod, "shift"], "Up",
        lazy.layout.shuffle_up()
    ),

    # Pull a group to the next screen
    Key(
        [mod, "shift"], "space",
        lazy.group.toscreen(1)
    ),

    Key([mod], "Return", lazy.spawn("xterm")),
    # NOTE: the bar can't be hidden easily at startup, and the spawncmd doesn't
    #       work anyway if the bar is hidden
    #Key([mod], "b", lazy.hide_show_bar()),
    # NOTE: without the bar, the spawncmd doesn't work
    #Key([mod], "p", lazy.spawncmd()),
    Key([mod], "f", lazy.window.disable_floating()),
    Key([mod], "space", lazy.next_urgent()),
    Key([mod, "shift"], "c", lazy.window.kill()),
    Key([mod, "shift"], "q", lazy.shutdown()),
    # NOTE: make sure the process exits with an error code in order for
    #       qtile-session to restart properly. When using lazy.restart(),
    #       the process exec to itself and add --no-spawn which automatically
    #       loads the default qtile configuration file if this file is broken.
    #       (This is very annoying, I want to fix my errors myself).
    Key(
        [mod, "shift"], "r",
        lazy.execute('/bin/sh', ['/bin/sh', '-c', 'exit 1'])
    ),

    # Special keys
    Key(
        [], "XF86AudioRaiseVolume",
        lazy.spawn("amixer set Master 2%+")
    ),
    Key(
        [], "XF86AudioLowerVolume",
        lazy.spawn("amixer set Master 2%-")
    ),
    Key(
        [], "XF86AudioMute",
        lazy.spawn("amixer set Master toggle")
    ),
    Key(
        [], "XF86MonBrightnessUp",
        lazy.spawn("sudo brightness up")
    ),
    Key(
        [], "XF86MonBrightnessDown",
        lazy.spawn("sudo brightness down")
    ),

]

groups = []
for i in range(1, 13):
    groups.append(Group(str(i)))
    # mod1 + F<i> = switch to group
    keys.append(
        Key([mod], "F%d" % i, lazy.group[str(i)].toscreen())
    )
    # mod1 + shift + F<i> = switch to & move focused window to group
    keys.append(
        Key([mod, "shift"], "F%d" % i, lazy.window.togroup(str(i)))
    )

layouts = [
    layout.Wmii(border_width=0, border_focus="#ffffff"),
]

widget_defaults = dict(
    font="Terminus",
    fontsize=16,
    padding=3,
)

screens = [
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
        start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
        start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(border_width=0)
auto_fullscreen = True
wmname = "LG3D"

@hook.subscribe.client_new
def hook_floating_windows(client):
    wm_class = client.window.get_wm_class()[1]
    if wm_class in floating_windows:
        client.floating = True

@hook.subscribe.client_new
def hoow_default_group(client):
    wm_class = client.window.get_wm_class()[1]
    if wm_class in default_windows_group:
        client.togroup(default_windows_group[wm_class])
