# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.backend.wayland import InputConfig

from widgets import GroupBox, PipeVolume
from layout import AutoSplit
from keys import NoEscKeyChord

import time
import os

SHIFT = "shift"
CTRL = "control"
META = "mod1"
NUMLK = "mod2"
HYPER = "mod3"
SUPER = "mod4"
LV3SH = "mod5"

terminal = guess_terminal()

GROUPS_MAX_INDEXES = 10, 5

reconfigure_screens = True

cursor_warp = True
follow_mouse_focus = True
bring_front_click = False

focus_on_window_activation = "urgent"

auto_minimize = False
auto_fullscreen = True
dgroups_key_binder = None
dgroups_app_rules = []

extension_default = {"font": "Source Code Pro",
                     "fontsize": 12,
                     "padding": 3}
WIDGETS_FONT = "Source Code Pro"
widget_default = {"font": WIDGETS_FONT,
                  "fontsize": 12,
                  "padding": 3}

keys = []
mouse = []
screens = []
groups = []
groups_struct = []
groups_prefixes = []
groups_suffixes = []
groups_compacted = []
groups_dict = {}
layouts = []

@hook.subscribe.startup_once
def startup_once():
    def refresh_kdeconnect():
        os.system("kdeconnect-cli --refresh &")
        qtile.call_later(5*60, refresh_kdeconnect)
    refresh_kdeconnect()

@lazy.function
def spawn_pings(_):
    current_layout = qtile.current_group.layout
    if isinstance(current_layout, AutoSplit):
        current_layout.special(AutoSplit.specials["pings"])
    os.system(f"sh -c \""
              f"{terminal} -e sh -c 'sleep 0.6; while true; do nmtui; done' &"
              f"sleep 0.1;"
              f"{terminal} -e sh -c 'dmesg -w' &"
              f"sleep 0.1;"
              f"{terminal} -e sh -c 'while true; do ping 1.1.1.1; sleep 1; done' &"
              f"sleep 0.1;"
              f"{terminal} -e sh -c 'while true; do ping myhome.ru; sleep 1; done' &"
              f"sleep 0.1;"
              f"{terminal} -e sh -c 'while true; do ping google.com; sleep 1; done' &"
              f"sleep 0.1;"
              f"{terminal} -e sh -c 'while true; do ping yandex.ru; sleep 1; done'\"&")

def configure_screen():
    screens.append(Screen(top=bar.Bar([widget.Chord(font=WIDGETS_FONT,
                                                    chords_colors={
                                                        "escape": ("#7f0000", "#ffffff"),
                                                        }),
                                       GroupBox(groups_struct,
                                                groups_prefixes,
                                                groups_suffixes,
                                                groups_compacted,
                                                font=WIDGETS_FONT,
                                                use_mouse_wheel=False,
                                                hide_unused=True,
                                                hide_unused_major=True,
                                                highlight_method="line",
                                                highlight_method_major="border"),
                                       widget.Prompt(font=WIDGETS_FONT,
                                                     bell_style="visual",
                                                     ignore_dups_history=True),
                                       widget.WindowName(font=WIDGETS_FONT,
                                                         width=bar.STRETCH),
                                       #widget.Countdown(date=datetime.datetime(2024, 12, 6)),
                                       widget.DF(font=WIDGETS_FONT,
                                                 format="{p} ({uf}{m}|{r:.0f}%)",
                                                 measure="G",
                                                 partition="/",
                                                 visible_on_warn=True,
                                                 foreground="#ffffff",
                                                 warn_color="#ffff00",
                                                 warn_space=3),
                                       widget.DF(font=WIDGETS_FONT,
                                                 format="{p} ({uf}{m}|{r:.0f}%)",
                                                 measure="G",
                                                 partition="/nix/",
                                                 visible_on_warn=True,
                                                 foreground="#ffffff",
                                                 warn_color="#ffff00",
                                                 warn_space=10),
                                       widget.Wlan(font=WIDGETS_FONT,
                                                   format="{essid}|{percent:2.0%}",
                                                   #interface="wlo1",
                                                   interface="wlp3s0",
                                                   update_interval=1),
                                       widget.Memory(font=WIDGETS_FONT,
                                                     format="({MemUsed:.0f}{mm}|{SwapUsed:.0f}{ms})",
                                                     measure_mem="M",
                                                     measure_swap="M"),
                                       widget.Sep(),
                                       PipeVolume(font=WIDGETS_FONT,
                                                  step=0,
                                                  channel="Master",
                                                  volume_down_command="pactl set-sink-volume @DEFAULT_SINK@ +2db",
                                                  volume_up_command="pactl set-sink-volume @DEFAULT_SINK@ -2db",
                                                  get_volume_command="timeout -s9 1s wpctl get-volume @DEFAULT_AUDIO_SINK@ || echo 'error'"),
                                       widget.Sep(),
                                       widget.Battery(font=WIDGETS_FONT,
                                                      charge_char="+",
                                                      discharge_char="-",
                                                      not_charging_char="=",
                                                      unknown_char="~",
                                                      show_short_text=True,
                                                      format="{char}{percent:2.1%} {hour:d}:{min:0>2d}",
                                                      foreground="#ffffff",
                                                      low_foreground="#ff0000",
                                                      low_percentage=0.15,
                                                      update_intervar=15),
                                       widget.Sep(),
                                       widget.Clock(font=WIDGETS_FONT,
                                                    format="%y/%m.%d(%u) %H:%M:%S",
                                                    update_interval=1.0)], 24)))

def configure_groups():
    for major in range(GROUPS_MAX_INDEXES[0]):
        groups_struct.append([
            Group(name=f"{major+1}-{minor+1}-{major+1}",
                  position=major*GROUPS_MAX_INDEXES[0]+minor,
                  label=f"{major+1}-{minor+1}-{major+1}")
            for minor in range(GROUPS_MAX_INDEXES[1])])
        groups_prefixes.append(f"{major+1}-")
        groups_suffixes.append(f"-{major+1}")
        groups_compacted.append(f"{major+1}-{major+1}")
    for major, minor_group in enumerate(groups_struct):
        for minor, group in enumerate(minor_group):
            groups.append(group)
            groups_dict[group.name] = (major, minor)

@lazy.function
def toggle_group(_, set_major=None, set_minor=None, toggle=False):
    cur_major, cur_minor = major, minor = groups_dict[qtile.current_group.name]
    if set_major is not None:
        if isinstance(set_major, int):
            major = set_major
        elif set_major == '+':
            if major < GROUPS_MAX_INDEXES[0]-1:
                major += 1
        elif set_major == '-':
            if major > 0:
                major -= 1
    if set_minor is not None:
        if isinstance(set_minor, int):
            minor = set_minor
        elif set_minor == '+':
            if minor < GROUPS_MAX_INDEXES[1]-1:
                minor += 1
        elif set_minor == '-':
            if minor > 0:
                minor -= 1
    if (len(groups_struct) > major) and (len(groups_struct[major]) > minor):
        group = qtile.groups_map[groups_struct[major][minor].name]
        if toggle == "smart":
            prev_major, prev_minor = (
                groups_dict[qtile.current_screen.previous_group.name]
                if hasattr(qtile.current_screen, "previous_group") else
                (cur_major, cur_minor)
            )
            toggle = (prev_major == major == cur_major)
        if toggle is True:
            qtile.current_screen.toggle_group(group)
        elif toggle is False:
            qtile.current_screen.set_group(group)

@lazy.function
def to_group(_,
             set_major= None,
             set_minor= None,
             switch_group=False,
             toggle=False):
    major, minor = groups_dict[qtile.current_group.name]
    if set_major is not None:
        if isinstance(set_major, int):
            major = set_major
        elif set_major == '+':
            if major < GROUPS_MAX_INDEXES[0]-1:
                major += 1
        elif set_major == '-':
            if major > 0:
                major -= 1
    if set_minor is not None:
        if isinstance(set_minor, int):
            minor = set_minor
        elif set_minor == '+':
            if minor < GROUPS_MAX_INDEXES[1]-1:
                minor += 1
        elif set_minor == '-':
            if minor > 0:
                minor -= 1
    if (len(groups_struct) > major) and (len(groups_struct[major]) > minor):
        window: Optional[Window] = qtile.current_group.current_window
        if window is not None:
            window.togroup(groups_struct[major][minor].name, switch_group=switch_group, toggle=toggle)


@lazy.function
def swap_groups(_,
                other_major= None,
                other_minor= None,
                switch_group=True):

    cur_major, cur_minor = groups_dict[qtile.current_group.name]

    if other_major == '+':
        if cur_major < GROUPS_MAX_INDEXES[0] - 1:
            other_major = cur_major + 1
        else:
            return
    elif other_major == '-':
        if cur_major > 0:
            other_major = cur_major - 1
        else:
            return
    elif other_major == '=':
        other_major = cur_major

    if other_minor == '+':
        if cur_minor < GROUPS_MAX_INDEXES[1] - 1:
            other_minor = cur_minor + 1
        else:
            return
    elif other_minor == '-':
        if cur_minor > 0:
            other_minor = cur_minor - 1
        else:
            return
    elif other_minor == '=':
        other_minor = cur_minor

    def _swap_groups(other_major= None,
                     other_minor= None,
                     _cur_major= None,
                     _cur_minor= None):
        cur_major, cur_minor = groups_dict[qtile.current_group.name]

        if _cur_major is not None:
            cur_major = _cur_major
        if _cur_minor is not None:
            cur_minor = _cur_minor

        if not isinstance(other_major, int):
            for major in range(GROUPS_MAX_INDEXES[0]):
                _swap_groups(major, other_minor, _cur_major=major)
        elif not isinstance(other_minor, int):
            for minor in range(GROUPS_MAX_INDEXES[1]):
                _swap_groups(other_major, minor, _cur_minor=minor)
        else:
            l1 = qtile.groups_map[groups_struct[cur_major][cur_minor].name].layout
            l2 = qtile.groups_map[groups_struct[other_major][other_minor].name].layout
            if l1 is l2:
                return
            if isinstance(l1, AutoSplit) and isinstance(l2, AutoSplit):
                l1.swap_layout(l2)

    _swap_groups(other_major=other_major, other_minor=other_minor)
    if switch_group:
        qtile.current_screen.set_group(qtile.groups_map[
                                           groups_struct[
                                               cur_major if other_major is None else other_major
                                           ][
                                               cur_minor if other_minor is None else other_minor
                                           ].name
                                       ])

def configure_controls():
    mouse.append(Click([SUPER], "Button1", lazy.window.bring_to_front()))
    mouse.append(Drag([SUPER],  "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()))

    common_keys = [
        Key([SUPER],        "f",            lazy.window.toggle_fullscreen()),

        #Key([SUPER],        "r",            lazy.spawncmd()),
        Key([SUPER],        "d",            lazy.spawn("wmenu-history")),

        Key([SUPER],        "XF86PowerOff", lazy.spawn("powerctl")),  # doesn't work!
        Key([HYPER],        "XF86PowerOff", lazy.spawn("powerctl")),  # doesn't work!
        Key([],        "XF86PowerOff", lazy.spawn("powerctl")),
        Key([SUPER, META],  "F9",           lazy.spawn("powerctl .Lock")),
        Key([SUPER, SHIFT], "F9",           lazy.spawn("powerctl .Xtrlock-s")),
        Key([SUPER, CTRL],  "F9",           lazy.spawn("powerctl .Xtrlock")),
        Key([HYPER],        "F9",           lazy.spawn("powerctl .Xtrlock")),

        Key([],             "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +2.5db")),
        Key([],             "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -2.5db")),
        Key([],             "XF86AudioMute",        lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
        Key([SHIFT],        "XF86AudioMute",
            lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ 100%"),
            lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ 0")),

        #Key([],             "XF86MonBrightnessDown", change_brightness("min(max(br_val/1.1, 0.05), 1)")),
        #Key([],             "XF86MonBrightnessUp",   change_brightness("min(max(br_val*1.1, 0.05), 1)")),
        #Key([SUPER],        "XF86MonBrightnessDown", change_brightness("br_val/1.1")),
        #Key([SUPER],        "XF86MonBrightnessUp",   change_brightness("br_val*1.1")),
        #Key([SHIFT],        "XF86MonBrightnessDown", change_brightness("1", fast=False)),
        #Key([SHIFT],        "XF86MonBrightnessUp",   change_brightness("0.05", fast=False)),
        #Key([CTRL],         "XF86MonBrightnessDown", change_brightness("0", fast=False)),

        #Key([],             "XF86TouchpadToggle", lazy.spawn(
        #    "bash -c \""
        #    "xinput list-props \\\"ELAN1200:00 04F3:309F Touchpad\\\" | "
        #    "grep \\\"Device Enabled\\\" | "
        #    "python -c \\\"print(0 if int(input().split(':')[1]) else 1)\\\" | "
        #    "xargs xinput set-prop \\\"ELAN1200:00 04F3:309F Touchpad\\\" \\\"Device Enabled\\\"\"")),

        #;; SUPER added due to frequent miss-presses
        Key([SUPER],        "Print", lazy.spawn("sh -c 'mkdir -p ~/Screenshots; grim ~/Screenshots/\"$(date +\"Screenshot - %y.%M.%d %H:%M:%S.png\")\"'")),
        Key([SUPER, META],  "c",     lazy.spawn("sh -c 'wl-paste --primary | wl-copy'")),
        Key([SUPER],        "c",     lazy.spawn("sh -c 'wl-paste --primary | wl-copy --primary && wl-paste | wl-copy'")),

        Key([SUPER, SHIFT], "c",     lazy.reload_config()),
        Key([SUPER, META],  "r",     lazy.restart()),

        #KeyChord([SUPER],        "p", [
        #    Key([SUPER],        "z", lazy.spawn("playerctl previous")),
        #    Key([SUPER],        "x", lazy.spawn("playerctl play")),
        #    Key([SUPER],        "c", lazy.spawn("playerctl play-pause")),
        #    Key([SUPER],        "v", lazy.spawn("playerctl stop")),
        #    Key([SUPER],        "b", lazy.spawn("playerctl next")),
        #    Key([],             "z", lazy.spawn("playerctl previous")),
        #    Key([],             "x", lazy.spawn("playerctl play")),
        #    Key([],             "c", lazy.spawn("playerctl play-pause")),
        #    Key([],             "v", lazy.spawn("playerctl stop")),
        #    Key([],             "b", lazy.spawn("playerctl next")),
        #]),
        #KeyChord([HYPER],        "p", [
        #    Key([HYPER],        "z", lazy.spawn("playerctl previous")),
        #    Key([HYPER],        "x", lazy.spawn("playerctl play")),
        #    Key([HYPER],        "c", lazy.spawn("playerctl play-pause")),
        #    Key([HYPER],        "v", lazy.spawn("playerctl stop")),
        #    Key([HYPER],        "b", lazy.spawn("playerctl next")),
        #    Key([],             "z", lazy.spawn("playerctl previous")),
        #    Key([],             "x", lazy.spawn("playerctl play")),
        #    Key([],             "c", lazy.spawn("playerctl play-pause")),
        #    Key([],             "v", lazy.spawn("playerctl stop")),
        #    Key([],             "b", lazy.spawn("playerctl next")),
        #]),

        Key([HYPER],        "h",     lazy.layout.left()),
        Key([HYPER],        "j",     lazy.layout.down()),
        Key([HYPER],        "k",     lazy.layout.up()),
        Key([HYPER],        "l",     lazy.layout.right()),
        Key([SUPER, CTRL],  "h",     lazy.layout.swap_left()),
        Key([SUPER, CTRL],  "j",     lazy.layout.swap_down()),
        Key([SUPER, CTRL],  "k",     lazy.layout.swap_up()),
        Key([SUPER, CTRL],  "l",     lazy.layout.swap_right()),
        Key([HYPER],        "Return", lazy.spawn(f"{terminal} -e fish")),
        #Key([HYPER, CTRL],  "Return", lazy.spawn(f"{terminal} -e fish --private")),
    ]

    keys.extend((Key([SUPER],        "Left",  lazy.layout.left()),
                 Key([SUPER],        "Down",  lazy.layout.down()),
                 Key([SUPER],        "Up",    lazy.layout.up()),
                 Key([SUPER],        "Right", lazy.layout.right()),
                 Key([SUPER],        "h",     lazy.layout.left()),
                 Key([SUPER],        "j",     lazy.layout.down()),
                 Key([SUPER],        "k",     lazy.layout.up()),
                 Key([SUPER],        "l",     lazy.layout.right()),
                 Key([SUPER, SHIFT], "Left",  lazy.layout.move_left()),
                 Key([SUPER, SHIFT], "Down",  lazy.layout.move_down()),
                 Key([SUPER, SHIFT], "Up",    lazy.layout.move_up()),
                 Key([SUPER, SHIFT], "Right", lazy.layout.move_right()),
                 Key([SUPER, SHIFT], "h",     lazy.layout.move_left()),
                 Key([SUPER, SHIFT], "j",     lazy.layout.move_down()),
                 Key([SUPER, SHIFT], "k",     lazy.layout.move_up()),
                 Key([SUPER, SHIFT], "l",     lazy.layout.move_right()),
                 Key([SUPER, META],  "Left",  lazy.layout.swap_left()),
                 Key([SUPER, META],  "Down",  lazy.layout.swap_down()),
                 Key([SUPER, META],  "Up",    lazy.layout.swap_up()),
                 Key([SUPER, META],  "Right", lazy.layout.swap_right()),
                 Key([SUPER, META],  "h",     lazy.layout.swap_left()),
                 Key([SUPER, META],  "j",     lazy.layout.swap_down()),
                 Key([SUPER, META],  "k",     lazy.layout.swap_up()),
                 Key([SUPER, META],  "l",     lazy.layout.swap_right()),

                 Key([SUPER, SHIFT], "q",     lazy.window.kill()),

                 Key([SUPER, SHIFT], "space", lazy.window.toggle_floating())))

    mouse.append(Drag([SUPER, META], "Button1", lazy.window.set_size_floating(), start=lazy.window.get_size()))

    common_keys.extend([
        Key([SUPER],        "s", toggle_group(set_major='-', toggle=False)),
        Key([SUPER],        "w", toggle_group(set_major='+', toggle=False)),
        Key([SUPER, META],  "s", swap_groups(other_major='-', switch_group=True)),
        Key([SUPER, META],  "w", swap_groups(other_major='+', switch_group=True)),
        Key([SUPER, CTRL],  "s", swap_groups(other_major='-', other_minor='=', switch_group=True)),
        Key([SUPER, CTRL],  "w", swap_groups(other_major='+', other_minor='=', switch_group=True)),
    ])
    keys.extend([
        Key([SUPER, SHIFT], "s", to_group(set_major='-')),
        Key([SUPER, SHIFT], "w", to_group(set_major='+')),
    ])

    for minor in range(GROUPS_MAX_INDEXES[1]):
        common_keys.append(
            Key([SUPER],        f"{minor+1}", toggle_group(set_minor=minor, toggle=False)))
        common_keys.append(
            Key([SUPER, META],  f"{minor+1}", swap_groups(other_major='=', other_minor=minor, switch_group=True)))
        keys.append(
            Key([SUPER, SHIFT], f"{minor+1}", to_group(set_minor=minor)))

    keys.extend([
        Key([SUPER],        "Return", lazy.spawn(f"{terminal} -e fish")),
        #Key([SUPER, META],  "Return", lazy.spawn(f"{terminal} -e fish --private")),
        Key([SUPER, META],  "n",      lazy.spawn(f"wezterm --config exit_behavior=\\\"Hold\\\" start sh -c 'sleep 0.1; fastfetch'")),  # it's too fast, lol!
        Key([SUPER, SHIFT], "Escape", lazy.spawn(f"{terminal} -e htop")),
        #Key([SUPER, META],  "Escape", lazy.spawn(f"{terminal} -e htop --readonly -t -u portage")),
        Key([SUPER, CTRL],  "F2",     lazy.spawn(f"vivaldi --profile-directory=Default")),
        Key([SUPER, META, CTRL], "F2",     lazy.spawn(f"vivaldi --profile-directory=Profile\\ 4")),
        Key([SUPER],        "F2",     lazy.spawn(f"sh -c 'librewolf --profile ~/.librewolf/default'")),
        Key([SUPER, SHIFT], "F2",     lazy.spawn(f"sh -c 'librewolf --profile ~/.librewolf/private'")),
        Key([SUPER, META],  "F2",     lazy.spawn(f"sh -c 'librewolf --profile ~/.librewolf/tor'")),
        Key([SUPER],        "F3",     lazy.spawn(f"{terminal} -e python")),
        Key([SUPER],        "F4",     lazy.spawn(f"{terminal} -e rlcl")),
        Key([SUPER],        "F6",     lazy.spawn(f"{terminal} -e sh -c 'sleep 0.1; while true; do nmtui; done'")),
        Key([SUPER],        "F7",     spawn_pings()),
        Key([SUPER],        "F8",     lazy.spawn(f"{terminal} -e nix repl")),
        #Key([SUPER],        "F12",    spawn_update()),
    ])

    #keys.extend([
    #    Key([SUPER, HYPER], "i",     lazy.spawn(f"xcalib -i -a")),
    #    Key([SUPER, HYPER], "h",     lazy.spawn(f"xrandr --output eDP1 --rotate left")),
    #    Key([SUPER, HYPER], "j",     lazy.spawn(f"xrandr --output eDP1 --rotate normal")),
    #    Key([SUPER, HYPER], "k",     lazy.spawn(f"xrandr --output eDP1 --rotate inverted")),
    #    Key([SUPER, HYPER], "l",     lazy.spawn(f"xrandr --output eDP1 --rotate right")),
    #    Key([SUPER, HYPER], "n",     lazy.spawn(f"xrandr --output eDP1 --reflect normal")),
    #    Key([SUPER, HYPER], "x",     lazy.spawn(f"xrandr --output eDP1 --reflect x")),
    #    Key([SUPER, HYPER], "y",     lazy.spawn(f"xrandr --output eDP1 --reflect y")),
    #    Key([SUPER, HYPER], "b",     lazy.spawn(f"xrandr --output eDP1 --reflect xy")),
    #])

    keys.extend(common_keys)

def configure_layouts():
    global floating_layout
    layouts.append(AutoSplit(border_color_focused="#007f7f",
                             border_color_unfocused="#2d2d2d",
                             border_width=2,
                             smart_borders=True))
    floating_layout = layout.Floating(float_rules=[*layout.Floating.default_float_rules])

def main():
    configure_screen()
    configure_groups()
    configure_controls()
    configure_layouts()
    keys.extend([
        #Key([SUPER],        "t", lazy.function(lambda _: qtile.core.hide_cursor())),
        #Key([SUPER],        "y", lazy.function(lambda _: qtile.core.unhide_cursor())),
        Key([SUPER],        "t", lazy.core.hide_cursor()),
        Key([SUPER],        "y", lazy.core.unhide_cursor()),
        ])

main()

keys.append(NoEscKeyChord([SUPER, META, CTRL, SHIFT],
                          "return",
                          [],
                          Key([SUPER, META, CTRL, SHIFT], "Escape", lazy.ungrab_chord()),
                          name="escape",
                          mode=True))

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

# When using the Wayland backend, this can be used to configure input devices.
"""
$ qtile cmd-obj -o core -f get_inputs
{'type:keyboard': [{'identifier': '0:1:Power Button', 'name': 'Power Button'},
                   {'identifier': '0:6:Video Bus', 'name': 'Video Bus'},
                   {'identifier': '0:6:Video Bus', 'name': 'Video Bus'},
                   {'identifier': '0:1:Power Button', 'name': 'Power Button'},
                   {'identifier': '0:0:Asus WMI hotkeys',
                    'name': 'Asus WMI hotkeys'},
                   {'identifier': '1:1:AT Translated Set 2 keyboard',
                    'name': 'AT Translated Set 2 keyboard'}],
 'type:pointer': [{'identifier': '1267:12447:ELAN1200:00 04F3:309F Mouse',
                   'name': 'ELAN1200:00 04F3:309F Mouse'}],
 'type:touchpad': [{'identifier': '1267:12447:ELAN1200:00 04F3:309F Touchpad',
                    'name': 'ELAN1200:00 04F3:309F Touchpad'}]}
"""
wl_input_rules = {"type:keyboard": InputConfig(kb_options=None,
                                               kb_layout="custom",
                                               kb_variant=None,
                                               kb_repeat_delay=500,
                                               kb_repeat_rate=50,
                                               kb_capslock=False,
                                               kb_numlock=True,
                                               xkb_capslock=False,
                                               xkb_numlock=True,
                                               ),
                  "type:touchpad": InputConfig(click_method="clickfinger",
                                               tap=True,
                                               natural_scroll=True,
                                               dwt=False,
                                               dwtp=False,
                                               scroll_method="two_finger",
                                               #  I want circular scrolling...
                                               #scroll_method="edge",
                                               pointer_accel=-0.1)}

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
#  wmname = "qtile"

# announce a running qtile session to systemd
os.system("systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP")
os.system("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=qtile")

