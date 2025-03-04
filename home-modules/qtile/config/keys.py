from copy import copy
import typing

from libqtile.config import Key, KeyChord


class NoEscKeyChord(KeyChord):
    """Define a key chord aka vim like mode

    Parameters
    ==========
    modifiers:
        A list of modifier specifications. Modifier specifications are one of:
        "shift", "lock", "control", "mod1", "mod2", "mod3", "mod4", "mod5".
    key:
        A key specification, e.g. "a", "Tab", "Return", "space".
    submappings:
        A list of Key or KeyChord declarations to bind in this chord.
    mode:
        A string with vim like mode name. If it's set, the chord mode will
        not be left after a keystroke (except for Esc which always leaves the
        current chord/mode).
    """

    def __init__(
        self,
        modifiers: list[str],
        key: str,
        submappings: list[typing.Union[Key, KeyChord, "NoEscKeyChord"]],
        exit_key: Key,
        name: str = "",
        mode: bool = True,
    ):
        super().__init__(modifiers, key, copy(submappings), name=name, mode=mode)

        submappings.append(exit_key)
        self.submappings = submappings

    def __repr__(self):
        return "<NoEscKeyChord (%s, %s)>" % (self.modifiers, self.key)


