from typing import Optional, Union, Iterable
from collections import OrderedDict
import weakref
import copy

from libqtile.config import ScreenRect
from libqtile.layout.base import Layout

from libqtile.backend.x11.window import Window


def no_ref() -> Optional[Union["WindowContainer", "NodesTypes"]]: return None


class WindowContainer:
    def __init__(self, client: Window, options: Optional[dict[str, any]] = None):
        self.client: Window = client
        self.parent: NodesTypes | None = None
        self.options = {
            "x": 0,
            "y": 0,
            "width": 800,
            "height": 600,
            "border_width": 0,
            "border_color": "#ffffff",
            "hide": False,
            "focused": False,
        }
        self.neighbors: weakref.WeakValueDictionary[str, WindowContainer] = weakref.WeakValueDictionary()
        self.neighbors_referenced: weakref.WeakKeyDictionary[WindowContainer, set[str]] = weakref.WeakKeyDictionary()
        if options is not None:
            self.options.update(options)

    def __repr__(self):
        return f"W[{' @'[self.options.get('focused')]}]"

    def get_root(self):
        node = self
        while node.parent is not None:
            node = node.parent
        return node

    def focus(self):
        self.options["focused"] = True
        self.parent.focus(self)
        self.parent.update_options()

    def unfocus(self):
        self.options["focused"] = False
        self.parent.unfocus(self)
        self.parent.update_options()

    def add_window(self, client: Window) -> "WindowContainer":
        node = WindowContainer(client)
        self.parent.add_window(node, self)
        return node

    def remove(self) -> Optional["WindowContainer"]:
        return self.parent.remove_window(self)

    def first_window(self) -> "WindowContainer":
        return self.parent.first_window()

    def last_window(self) -> "WindowContainer":
        return self.parent.last_window()

    def next_window(self, window: "WindowContainer") -> Optional["WindowContainer"]:
        return self.parent.previous_window(window)

    def previous_window(self, window: "WindowContainer") -> Optional["WindowContainer"]:
        return self.parent.next_window(window)

    def configure(self):
        x = self.options.get("x")
        y = self.options.get("y")
        width = self.options.get("width")
        height = self.options.get("height")
        border_width = self.options.get("border_width")
        border_color = self.options.get("border_color")
        self.client.place(
            x,
            y,
            width - 2*border_width,
            height - 2*border_width,
            border_width,
            border_color,
        )
        if self.options.get("hide"):
            self.client.hide()
        else:
            # libqtile.backend.wayland.xdgwindow.XdgWindow has no attribute window
            #self.client.window.configure(stackmode=1)
            self.client.unhide()

    def distance_to(self, x: int, y: int) -> int:
        x -= self.options.get("x")
        y -= self.options.get("y")
        width = self.options.get("width")
        height = self.options.get("height")
        neg_x = x < 0
        neg_y = y < 0
        pos_x = x >= width
        pos_y = y >= height
        return \
            neg_x*(-x) + \
            neg_y*(-y) + \
            pos_x*(x-width) + \
            pos_y*(y-height)

    def update_neighbors(self, direction=None):
        x = self.options.get("x")
        y = self.options.get("y")
        width = self.options.get("width")
        height = self.options.get("height")
        if (direction in (None, "left")) and ("left" in self.neighbors):
            if self.neighbors.get("left").distance_to(x, y+height//2) != 0:
                neighbor = self.neighbors.pop("left")
                if self in neighbor.neighbors_referenced:
                    neighbor.neighbors_referenced[self].remove("left")
        if (direction in (None, "right")) and ("right" in self.neighbors):
            if self.neighbors.get("right").distance_to(x+width, y+height//2) != 0:
                neighbor = self.neighbors.pop("right")
                if self in neighbor.neighbors_referenced:
                    neighbor.neighbors_referenced[self].remove("right")
        if (direction in (None, "up")) and ("up" in self.neighbors):
            if self.neighbors.get("up").distance_to(x+width//2, y) != 0:
                neighbor = self.neighbors.pop("up")
                if self in neighbor.neighbors_referenced:
                    neighbor.neighbors_referenced[self].remove("up")
        if (direction in (None, "down")) and ("down" in self.neighbors):
            if self.neighbors.get("down").distance_to(x+width//2, y+height) != 0:
                neighbor = self.neighbors.pop("down")
                if self in neighbor.neighbors_referenced:
                    neighbor.neighbors_referenced[self].remove("down")
        if direction is None:
            for neighbor, neighbor_directions in self.neighbors_referenced.items():
                for neighbor_direction in neighbor_directions.copy():
                    neighbor.update_neighbors(neighbor_direction)


class SplitNode:
    def __init__(self, options: Optional[dict[str, any]] = None):
        self.parent: NodesTypes | None = None
        self.nodes: list[NodesTypes | WindowContainer] = []
        self.focused: callable = no_ref
        self.options = {
            "x": 0,
            "y": 0,
            "width": 800,
            "height": 600,
            "border_width": 0,
            "border_color": "#7f7f7f",
            "border_color_focused": "#ffffff",
            "border_color_unfocused": "#7f7f7f",
            "hide": False,
            "is_vertical": False,
            "focused": False,
        }
        if options is not None:
            self.options.update(options)

    def __repr__(self):
        return f"{'HV'[self.options.get('is_vertical')]}{repr(self.nodes)}"

    def collapse(self):
        if len(self.nodes) == 0:
            if self.parent is not None:
                self.parent.nodes.remove(self)  # the only link
            else:
                pass  # no links
        elif len(self.nodes) == 1:
            if self.parent is not None:
                self.parent.replace(self, self.nodes)  # both links
            else:
                if isinstance(self.nodes[0], WindowContainer):
                    self.options["is_vertical"] = False
                    self.update_options()  # no collapse
                else:
                    self.nodes[0].parent = None  # the only link
        else:
            while True:
                for node in self.nodes:
                    if isinstance(node, SplitNode):
                        if self.options.get("is_vertical") == node.options.get("is_vertical"):
                            self.replace(node, node.nodes)
                            break
                else:
                    break
            if self.parent is not None:
                if isinstance(self.parent, SplitNode):
                    if self.parent.options.get("is_vertical") == self.options.get("is_vertical"):
                        self.parent.replace(self, self.nodes)  # both links
                        return
            self.update_options()  # no collapse

    def replace(self,
                node: Union["NodesTypes", WindowContainer], nodes: Iterable[Union["NodesTypes", WindowContainer]]):
        index = self.nodes.index(node)
        self.nodes = self.nodes[:index] + [*nodes] + self.nodes[index+1:]
        for node in nodes:
            node.parent = self
        self.collapse()

    def update_options(self, update_neighbors=True):
        size = len(self.nodes)
        focused = self.focused()
        for index, child in enumerate(self.nodes):
            is_focused = focused is child
            if self.options.get("is_vertical"):
                dy = self.options.get("height") * index // size
                child.options["x"] = self.options.get("x")
                child.options["y"] = self.options.get("y") + dy
                child.options["width"] = self.options.get("width")
                child.options["height"] = (self.options.get("height") * (index+1))//size - dy
            else:
                dx = self.options.get("width") * index // size
                child.options["x"] = self.options.get("x") + dx
                child.options["y"] = self.options.get("y")
                child.options["width"] = (self.options.get("width") * (index+1))//size - dx
                child.options["height"] = self.options.get("height")
            child.options["border_width"] = self.options.get("border_width")
            child.options["border_color"] = self.options.get(
                "border_color_focused"
                if is_focused else
                "border_color_unfocused"
                if self.parent is None else
                "border_color"
            )
            child.options["hide"] = self.options.get("hide")
            if isinstance(child, SplitNode):
                child.options["is_vertical"] = not self.options.get("is_vertical")
            if not isinstance(child, WindowContainer):
                child.update_options(update_neighbors=False)
            child.options["focused"] = focused is child
        if update_neighbors:
            self.update_neighbors()

    def update_neighbors(self):
        for node in self.nodes:
            node.update_neighbors()

    def focus(self, node: Union["NodesTypes", WindowContainer]):
        self.focused = weakref.ref(node)
        self.options["focused"] = True
        if self.parent is not None:
            self.parent.focus(self)

    def unfocus(self, node: Union["NodesTypes", WindowContainer]):
        self.focused = no_ref
        self.options["focused"] = False
        if self.parent is not None:
            self.parent.unfocus(self)

    def get_near(self, node: Union["NodesTypes", WindowContainer]) -> WindowContainer | None:
        if len(self.nodes) < 2:
            if self.parent is not None:
                return self.parent.get_near(self)
            else:
                return None
        index = self.nodes.index(node)
        if index == len(self.nodes)-1:
            if isinstance(self.nodes[index-1], NodesTypes):
                return self.nodes[index-1].last_window(ignore_parent=True)
            return self.nodes[index-1]
        else:
            if isinstance(self.nodes[index+1], NodesTypes):
                return self.nodes[index+1].first_window(ignore_parent=True)
            return self.nodes[index+1]

    def add_window(self, new_window: WindowContainer, window: WindowContainer = None):
        if window is not None:
            self.nodes.insert(self.nodes.index(window)+1, new_window)
        else:
            self.nodes.append(new_window)
        new_window.parent = self
        self.update_options()

    def remove_window(self, window: WindowContainer) -> Optional[WindowContainer]:
        near = self.get_near(window)
        self.nodes.remove(window)
        self.collapse()
        return near

    def first_window(self, ignore_parent=False) -> WindowContainer:
        if (self.parent is None) or ignore_parent:
            if isinstance(self.nodes[0], NodesTypes):
                return self.nodes[0].first_window(ignore_parent=True)
            return self.nodes[0]
        else:
            return self.parent.first_window()

    def last_window(self, ignore_parent=False) -> WindowContainer:
        if (self.parent is None) or ignore_parent:
            if isinstance(self.nodes[-1], NodesTypes):
                return self.nodes[-1].last_window(ignore_parent=True)
            return self.nodes[-1]
        else:
            return self.parent.last_window()

    def previous_window(self, node: Union["NodesTypes", WindowContainer]) -> Optional[WindowContainer]:
        index = self.nodes.index(node)
        if index == 0:
            if self.parent is not None:
                return self.parent.previous_window(self)
            return None
        elif isinstance(self.nodes[index-1], NodesTypes):
            return self.nodes[index-1].first_window(ignore_parent=True)

    def next_window(self, node: Union["NodesTypes", WindowContainer]) -> Optional[WindowContainer]:
        index = self.nodes.index(node)
        if index == len(self.nodes)-1:
            if self.parent is not None:
                return self.parent.next_window(self)
            return None
        elif isinstance(self.nodes[index-1], NodesTypes):
            return self.nodes[index-1].last_window(ignore_parent=True)

    def _move(self, window: WindowContainer, vertical, to_start, direction):
        if self.options.get("is_vertical") == vertical:
            index = self.nodes.index(window)
            if to_start:
                if index != 0:
                    next_node = self.nodes[index-1]
                    if isinstance(next_node, WindowContainer):
                        new_node = SplitNode(self.options)
                        new_node.options["is_vertical"] = not self.options.get("is_vertical")
                        new_node.nodes = [next_node, window]
                        next_node.parent = new_node
                        window.parent = new_node
                        self.nodes.remove(window)
                        self.replace(next_node, (new_node, ))
                    else:
                        self.nodes.remove(window)
                        next_node.move_into(window, direction)
                        self.collapse()
                    return
            else:
                if index < len(self.nodes)-1:
                    next_node = self.nodes[index+1]
                    if isinstance(next_node, WindowContainer):
                        new_node = SplitNode(self.options)
                        new_node.options["is_vertical"] = not self.options.get("is_vertical")
                        new_node.nodes = [next_node, window]
                        next_node.parent = new_node
                        window.parent = new_node
                        self.nodes.remove(window)
                        self.replace(next_node, (new_node, ))
                    else:
                        self.nodes.remove(window)
                        next_node.move_into(window, direction)
                        self.collapse()
                    return
        if self.parent is None:
            self.parent = SplitNode(self.options)
            self.parent.options["is_vertical"] = vertical
            self.parent.nodes.append(self)
        self.nodes.remove(window)
        self.parent.move_from(window, self, direction)

    def move_into(self, window: WindowContainer, direction):
        vertical = direction in ("up", "down")
        to_start = direction in ("left", "up")
        window.parent = self
        if self.options.get("is_vertical") == vertical:
            self.nodes.insert((0 if to_start else len(self.nodes)), window)
        else:
            self.nodes.append(window)
        self.update_options()

    def move_from(self, window: WindowContainer, node: "NodesTypes", direction):
        vertical = direction in ("up", "down")
        to_start = direction in ("left", "up")
        index = self.nodes.index(node)
        if self.options.get("is_vertical") == vertical:
            window.parent = self
            self.nodes.insert(index + (not to_start), window)
            node.collapse()
            self.collapse()
            return
        if self.parent is None:
            self.parent = SplitNode(self.options)
            self.parent.options["is_vertical"] = vertical
            self.parent.nodes.append(self)
        self.parent.move_from(window, self, direction)
        # if you are trying to figure out why sometimes a lot of windows
        #  displayed as focused, this is where something goes wrong:
        #  NOTE: final collapsing sequence:
        #   1 parent   \
        #   2 self     _} happens in self.parent.move_from
        #   3 node
        #   4 self
        #   5 parent
        node.collapse()
        self.collapse()
        self.parent.collapse()

    def move_left(self, window: WindowContainer):
        self._move(window, False, True, "left")

    def move_right(self, window: WindowContainer):
        self._move(window, False, False, "right")

    def move_up(self, window: WindowContainer):
        self._move(window, True, True, "up")

    def move_down(self, window: WindowContainer):
        self._move(window, True, False, "down")


NodesTypes = SplitNode


class AutoSplit(Layout):
    defaults = [

    ]

    specials = {
        "pings":  0x00,  # 0x00, 0x01, 0x02, 0x03, 0x04
        "update": 0x10,  # 0x10, 0x11, 0x12
    }

    def __init__(self, **options):
        super().__init__(**options)
        self.cur_specials = set()
        self.add_defaults(AutoSplit.defaults)
        self.nodes: dict[Window, WindowContainer] = dict()
        self.focused: Optional[WindowContainer] = None
        self.options = {}
        if "border_width" in options:
            self.options["border_width"] = options["border_width"]
        if "border_color_focused" in options:
            self.options["border_color_focused"] = options["border_color_focused"]
        if "border_color_unfocused" in options:
            self.options["border_color_unfocused"] = options["border_color_unfocused"]
        if "smart_borders" in options:
            self.options["smart_borders"] = options["smart_borders"]

    def __del__(self):
        return  # this is broken
        for node in self.nodes.values():
            node.remove()  # prevent reference cycle

    def clone(self, group):
        """Duplicate a layout

        Make a copy of this layout. This is done to provide each group with a
        unique instance of every layout.

        Parameters
        ==========
        group:
            Group to attach new layout instance to.
        """
        clone = super().clone(group)
        #clone = copy.copy(self)
        #clone.group = group
        clone.cur_specials = set()
        clone.nodes = OrderedDict()
        clone.focused = None
        return clone

    def focus(self, client: Window):
        if self.focused is not None:
            self.focused.unfocus()
        if client in self.nodes:
            self.focused = self.nodes[client]
            self.focused.focus()
        else:
            self.focused = None

    def focus_win(self, window: WindowContainer):
        if self.focused is not None:
            self.focused.unfocus()
        self.focused = window
        self.focused.focus()
        self.group.focus(self.focused.client)

    def refocus(self):
        self.focused.focus()
        self.group.focus(self.focused.client)
        if self.focused.client.qtile.config.cursor_warp:
            # libqtile.backend.wayland.xdgwindow.XdgWindow has no attribute window
            #self.focused.client.window.warp_pointer(self.focused.client.width // 2, self.focused.client.height // 2)
            pass

    def add_client(self, client):
        return self.add(client)

    def add(self, client: Window):
        """Called whenever a window is added to the group

        Called whether the layout is current or not. The layout should just add
        the window to its internal datastructures, without mapping or
        configuring.
        """
        if val := self.cur_specials.intersection({0x00, 0x01, 0x02, 0x03, 0x04}):
            val = val.pop()
            self.cur_specials.remove(val)
            self.add(client)
            if val == 0x00:
                self.cur_specials.add(0x01)
            if val == 0x01:
                self.cmd_move_left()
                self.cur_specials.add(0x02)
            if val == 0x02:
                self.cur_specials.add(0x03)
            if val == 0x03:
                self.cmd_move_right()
                self.cur_specials.add(0x04)
            if val == 0x04:
                self.cmd_move_left()
        if val := self.cur_specials.intersection({0x10, 0x11, 0x12}):
            val = val.pop()
            self.cur_specials.remove(val)
            self.add(client)
            if val == 0x10:
                self.cmd_move_up()
                self.cur_specials.add(0x11)
            if val == 0x11:
                self.cmd_move_right()
                self.cur_specials.add(0x12)
            if val == 0x12:
                self.cmd_move_left()

        if client in self.nodes:
            return
        if self.focused is None:
            if self.nodes:
                node = next(iter(self.nodes.values())).add_window(client)
            else:
                root: NodesTypes = SplitNode(self.options)
                node = WindowContainer(client, self.options)
                root.add_window(node)
        else:
            node = self.focused.add_window(client)
        self.nodes[client] = node
        self.focused = node
        self.focused.focus()

    def remove(self, client: Window):
        """Called whenever a window is removed from the group

        Called whether the layout is current or not. The layout should just
        de-register the window from its data structures, without unmapping the
        window.

        Returns the "next" window that should gain focus or None.
        """
        if client not in self.nodes:
            return
        node = self.nodes.pop(client)
        if self.focused is node:
            self.focused = node.remove()
            if self.focused is not None:
                self.focused.focus()
        else:
            node.remove()

    def configure(self, client: Window, screen_rect: ScreenRect):
        """Configure the layout

        This method should:

            - Configure the dimensions and borders of a window using the
              `.place()` method.
            - Call either `.hide()` or `.unhide()` on the window.
        """
        x = screen_rect.x
        y = screen_rect.y
        width = screen_rect.width
        height = screen_rect.height
        if self.options.get("smart_borders", False):
            border_width = self.options.get("border_width", 0)
            x -= border_width
            y -= border_width
            width += border_width*2
            height += border_width*2
            # wayland backend broke it
            y += border_width
            height -= border_width*1
        root = self.nodes[client].get_root()
        if (
                root.options.get("x") != x or
                root.options.get("y") != y or
                root.options.get("width") != width or
                root.options.get("height") != height
        ):
            root.options.update(
                x=x,
                y=y,
                width=width,
                height=height,
            )
            root.update_options()
        self.nodes[client].configure()

    def focus_first(self):
        """Called when the first client in Layout shall be focused.

        This method should:
            - Return the first client in Layout, if any.
            - Not focus the client itself, this is done by caller.
        """
        if self.focused is not None:
            return self.focused.first_window().client
        return None

    def focus_last(self):
        """Called when the last client in Layout shall be focused.

        This method should:
            - Return the last client in Layout, if any.
            - Not focus the client itself, this is done by caller.
        """
        if self.focused is not None:
            return self.focused.last_window().client
        return None

    def next(self, win):
        return self.focus_next(win)

    def previous(self, win):
        return self.focus_previous(win)

    def focus_next(self, win: Window):
        """Called when the next client in Layout shall be focused.

        This method should:
            - Return the next client in Layout, if any.
            - Return None if the next client would be the first client.
            - Not focus the client itself, this is done by caller.

        Do not implement a full cycle here, because the Groups cycling relies
        on returning None here if the end of Layout is hit,
        such that Floating clients are included in cycle.

        Parameters
        ==========
        win:
            The currently focused client.
        """
        if self.focused is not None:
            node = self.focused.next_window(self.nodes[win])
            if node is not None:
                return node.client
        return None

    def focus_previous(self, win: Window):
        """Called when the previous client in Layout shall be focused.

        This method should:
            - Return the previous client in Layout, if any.
            - Return None if the previous client would be the last client.
            - Not focus the client itself, this is done by caller.

        Do not implement a full cycle here, because the Groups cycling relies
        on returning None here if the end of Layout is hit,
        such that Floating clients are included in cycle.

        Parameters
        ==========
        win:
            The currently focused client.
        """
        if self.focused is not None:
            node = self.focused.next_window(self.nodes[win])
            if node is not None:
                return node.client
        return None

    def cmd_next(self):
        pass

    def cmd_previous(self):
        pass

    def get_direction(self, direction: str) -> Optional[WindowContainer]:
        if self.focused is not None:
            if direction in self.focused.neighbors:
                next_win = self.focused.neighbors.get(direction)
            else:
                x_pos, y_pos = {
                    "left": (
                        self.focused.options.get("x"),
                        self.focused.options.get("y") +
                        self.focused.options.get("height")//2
                    ),
                    "right": (
                        self.focused.options.get("x") +
                        self.focused.options.get("width"),
                        self.focused.options.get("y") +
                        self.focused.options.get("height")//2
                    ),
                    "up": (
                        self.focused.options.get("x") +
                        self.focused.options.get("width")//2,
                        self.focused.options.get("y")
                    ),
                    "down": (
                        self.focused.options.get("x") +
                        self.focused.options.get("width")//2,
                        self.focused.options.get("y") +
                        self.focused.options.get("height")
                    ),
                }[direction]
                next_win = None
                distance = None
                for node in self.nodes.values():
                    if node is not self.focused:
                        node_distance = node.distance_to(x_pos, y_pos)
                        if (next_win is None) or (node_distance < distance):
                            distance = node_distance
                            next_win = node
                            if distance == 0:
                                break
                if next_win is None:
                    return
                if distance == 0:
                    self.focused.neighbors[direction] = next_win
                    next_win.neighbors_referenced.setdefault(self.focused, default=set()).add(direction)
            opposite_direction = {"left": "right", "right": "left", "up": "down", "down": "up"}[direction]
            next_win.neighbors[opposite_direction] = self.focused
            self.focused.neighbors_referenced.setdefault(next_win, default=set()).add(opposite_direction)
            return next_win

    def cmd_left(self):
        next_win = self.get_direction("left")
        if next_win is not None:
            self.focus_win(next_win)

    def cmd_right(self):
        next_win = self.get_direction("right")
        if next_win is not None:
            self.focus_win(next_win)

    def cmd_up(self):
        next_win = self.get_direction("up")
        if next_win is not None:
            self.focus_win(next_win)

    def cmd_down(self):
        next_win = self.get_direction("down")
        if next_win is not None:
            self.focus_win(next_win)

    def cmd_move_left(self):
        if self.focused is not None:
            self.focused.parent.move_left(self.focused)
            self.refocus()

    def cmd_move_right(self):
        if self.focused is not None:
            self.focused.parent.move_right(self.focused)
            self.refocus()

    def cmd_move_up(self):
        if self.focused is not None:
            self.focused.parent.move_up(self.focused)
            self.refocus()

    def cmd_move_down(self):
        if self.focused is not None:
            self.focused.parent.move_down(self.focused)
            self.refocus()

    def swap(self, other: WindowContainer):
        client1 = self.focused.client
        client2 = other.client
        self.focused.client = client2
        other.client = client1
        self.nodes[client2] = self.focused
        self.nodes[client1] = other
        self.focused.unfocus()
        self.focused = other
        self.refocus()

    def cmd_swap_left(self):
        if self.focused is not None:
            other = self.get_direction("left")
            if other is not None:
                self.swap(other)

    def cmd_swap_right(self):
        if self.focused is not None:
            other = self.get_direction("right")
            if other is not None:
                self.swap(other)

    def cmd_swap_up(self):
        if self.focused is not None:
            other = self.get_direction("up")
            if other is not None:
                self.swap(other)

    def cmd_swap_down(self):
        if self.focused is not None:
            other = self.get_direction("down")
            if other is not None:
                self.swap(other)

    def swap_layout(self, other: "AutoSplit"):
        self.nodes, other.nodes = other.nodes, self.nodes
        self_focused = self.focused
        other_focused = other.focused

        self.focused = None
        other.focused = None

        w1 = copy.copy(self.group.windows)
        w2 = copy.copy(other.group.windows)
        for window in w1:
            window.togroup(other.group.name)
        for window in w2:
            window.togroup(self.group.name)

        if self.focused is not None:
            self.focused.unfocus()
        if other.focused is not None:
            other.focused.unfocus()

        self.focused = other_focused
        other.focused = self_focused
        if self.focused is not None:
            self.refocus()
        if other.focused is not None:
            other.refocus()

    def special(self, special_id):
        self.cur_specials.add(special_id)
