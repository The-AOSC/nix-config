import re
import subprocess
from collections import namedtuple
import itertools
from functools import partial
from typing import Any

from libqtile import bar, hook
from libqtile.config import Group
from libqtile.widget.groupbox import GroupBox as DefaultGroupBox
from libqtile.widget.volume import Volume as DefaultVolume

import os
import encodings

GroupsNamesPart = namedtuple("Groups_names_part", [
    "text", "is_minor", "is_focused", "is_empty", "is_urgent", "screen"
])


class GroupBox(DefaultGroupBox):
    defaults = [
        (
            "highlight_method_major",
            "border",
            "Method of highlighting ('border', 'block', 'text', or 'line')"
            "Uses `*_border` color settings",
        ),
        (
            "hide_unused_major",
            False,
            "Hide groups that have no windows and that are not displayed on any screen.",
        ),
    ]

    def __init__(self, groups_struct, groups_prefixes, groups_suffixes, groups_compacted, /, **config):
        super().__init__(**config)
        self.add_defaults(GroupBox.defaults)
        self.groups_struct: list[list[Group]] = groups_struct
        self.groups_prefixes: list[str] = groups_prefixes
        self.groups_suffixes: list[str] = groups_suffixes
        self.groups_compacted: list[str] = groups_compacted

    def get_group(self, name):
        def check_name(group):
            return group.name == name

        try:
            return iter(filter(check_name, self.qtile.groups)).__next__()
        except StopIteration:
            return

    @property
    def groups_names_parts(self):
        focused_group_name: str = self.bar.screen.group.name
        for groups_group, groups_prefix, groups_suffix, groups_compact in zip(
                self.groups_struct, self.groups_prefixes, self.groups_suffixes, self.groups_compacted):
            if focused_group_name.startswith(groups_prefix):
                is_urgent = False
                for group in groups_group:
                    if len([w for w in self.get_group(group.name).windows if w.urgent]):
                        is_urgent = True
                        break
                is_empty = True
                for group in groups_group:
                    if self.get_group(group.name).windows:
                        is_empty = False
                        break
                yield GroupsNamesPart(text=groups_prefix, is_minor=False, is_focused=True,
                                      is_empty=is_empty, is_urgent=is_urgent,
                                      screen=self.bar.screen.group.screen)
                for group in groups_group:
                    is_focused_minor = focused_group_name == group.name
                    is_empty_minor = not self.get_group(group.name).windows
                    if not (self.hide_unused and is_empty_minor) or (focused_group_name == group.name):
                        yield GroupsNamesPart(text=group.label.removeprefix(groups_prefix).removesuffix(groups_suffix),
                                              is_minor=True,
                                              is_focused=is_focused_minor,
                                              is_empty=is_empty_minor,
                                              is_urgent=bool(len([
                                                  w for w in self.get_group(group.name).windows
                                                  if w.urgent
                                              ])),
                                              screen=self.get_group(group.name).screen)
                yield GroupsNamesPart(text=groups_suffix, is_minor=False, is_focused=True,
                                      is_empty=is_empty, is_urgent=is_urgent,
                                      screen=self.bar.screen.group.screen)
            else:
                is_empty = True
                for group in groups_group:
                    if self.get_group(group.name).windows:
                        is_empty = False
                        break
                else:
                    if self.hide_unused_major:
                        continue
                is_urgent = False
                for group in groups_group:
                    if len([w for w in self.get_group(group.name).windows if w.urgent]):
                        is_urgent = True
                        break
                yield GroupsNamesPart(text=groups_compact, is_minor=False, is_focused=False, is_empty=is_empty,
                                      is_urgent=is_urgent, screen=self.get_group(groups_group[0].name).screen)

    def get_clicked_group(self):
        group = None
        new_width = self.margin_x - self.spacing / 2.0
        width = 0
        for g in self.groups:
            new_width += self.box_width([g]) + self.spacing
            if width <= self.click <= new_width:
                group = g
                break
            width = new_width
        return group

    def calculate_length(self):
        width = self.margin_x * 2
        count = 0
        for count, groups_names_part in enumerate(self.groups_names_parts):
            width += self.box_width([groups_names_part.text])
        width += (count - 1) * self.spacing
        return width

    def box_width(self, groups_or_labels):
        width, _ = self.drawer.max_layout_size(
            [
                i if isinstance(i, str) else i.label
                for i in groups_or_labels
            ], self.font, self.fontsize
        )
        return width + self.padding_x * 2 + self.borderwidth * 2

    def draw(self):
        self.drawer.clear(self.background or self.bar.background)

        offset = self.margin_x
        for i, groups_names_part in enumerate(self.groups_names_parts):
            text = groups_names_part.text
            is_empty = groups_names_part.is_empty
            is_focused = groups_names_part.is_focused
            is_minor = groups_names_part.is_minor
            is_urgent = groups_names_part.is_urgent
            group_screen = groups_names_part.screen  # TODO: None?

            to_highlight = False
            is_block = (self.highlight_method_major, self.highlight_method)[is_minor] == "block"
            is_line = (self.highlight_method_major, self.highlight_method)[is_minor] == "line"

            bw = self.box_width([text])

            if is_urgent and self.urgent_alert_method == "text":
                text_color = self.urgent_text
            elif not is_empty:
                text_color = self.active
            else:
                text_color = self.inactive

            if group_screen:
                if (self.highlight_method_major, self.highlight_method)[is_minor] == "text":
                    border = None
                    text_color = self.this_current_screen_border
                else:
                    if self.block_highlight_text_color:
                        text_color = self.block_highlight_text_color
                    if is_focused:
                        if self.qtile.current_screen == self.bar.screen:
                            border = self.this_current_screen_border
                            to_highlight = True
                        else:
                            border = self.this_screen_border
                    else:
                        if self.qtile.current_screen == group_screen:
                            border = self.other_current_screen_border
                        else:
                            border = self.other_screen_border
            elif is_urgent and self.urgent_alert_method in (
                "border",
                "block",
                "line",
            ):
                border = self.urgent_border
                if self.urgent_alert_method == "block":
                    is_block = True
                elif self.urgent_alert_method == "line":
                    is_line = True
            else:
                border = None

            self.drawbox(
                offset,
                text,
                border,
                text_color,
                highlight_color=self.highlight_color,
                width=bw,
                rounded=self.rounded,
                block=is_block,
                line=is_line,
                highlighted=to_highlight,
            )
            offset += bw + self.spacing

        self.drawer.draw(offsetx=self.offsetx, offsety=self.offsety, width=self.width)


re_vol = re.compile(r"(\d+\.\d\d)")


import time
class PipeVolume(DefaultVolume):
    def get_volume(self):
        try:
            get_volume_cmd = self.create_amixer_command("sget", self.channel)

            if self.get_volume_command:
                get_volume_cmd = self.get_volume_command

            #mixer_out = self.call_process(get_volume_cmd)
            read, write = os.pipe()
            res = os.fork()
            if res:
                os.close(write)
                mixer_out = encodings.utf_8.decode(os.read(read, 1024), "ignore")[0]
                os.close(read)
                os.wait4(res, 0)
            else:
                os.close(read)
                os.dup2(write, 1)
                os.close(write)
                os.execlp("sh", "sh", "-c", get_volume_cmd)
        except subprocess.CalledProcessError:
            return -1, False

        if "error" in mixer_out:
            return -1, False

        volgroups = re_vol.search(mixer_out)
        if volgroups:
            return int(volgroups.groups()[0].replace(".", "")), ("[MUTED]" in mixer_out)
        else:
            # this shouldn't happen
            return -1, False

