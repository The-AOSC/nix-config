{
  config,
  lib,
  ...
}: {
  options = {
    modules.wezterm.enable = lib.mkEnableOption "wezterm";
  };
  config = lib.mkIf config.modules.wezterm.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local config = {}

        ${lib.optionalString config.catppuccin.wezterm.enable ''
          config.color_scheme = "${config.programs.wezterm.colorSchemes."catppuccin-${config.catppuccin.wezterm.flavor}".metadata.name}"
        ''}

        --config.front_end = "OpenGL"
        --config.front_end = "WebGpu"
        config.enable_wayland = false

        config.font = wezterm.font("Source Code Pro", {weight="Regular", stretch="Normal", style="Normal"})
        config.font_size = 10.0

        config.scrollback_lines = 10000

        config.hide_tab_bar_if_only_one_tab = true
        config.enable_scroll_bar = false
        config.window_padding = {
          left = "0px",
          right = "0px",
          top = "0px",
          bottom = "0px",
        }

        config.check_for_updates = false

        config.window_close_confirmation = "NeverPrompt"
        config.exit_behavior_messaging = "None"

        config.disable_default_key_bindings = true

        config.keys = {
          {key = "c",             mods = "CTRL|SHIFT",  action = wezterm.action.CopyTo "ClipboardAndPrimarySelection"},
          {key = "v",             mods = "CTRL|SHIFT",  action = wezterm.action.PasteFrom "Clipboard"},
          {key = "0",             mods = "CTRL",        action = wezterm.action.ResetFontSize},
          {key = "-",             mods = "CTRL",        action = wezterm.action.DecreaseFontSize},
          {key = "=",             mods = "CTRL",        action = wezterm.action.IncreaseFontSize},
          {key = "F2",            mods = "CTRL|SHIFT",  action = wezterm.action.ActivateCommandPalette},
          {key = "Space",         mods = "CTRL|SHIFT",  action = wezterm.action.Multiple {
            wezterm.action.ActivateCopyMode,
            wezterm.action.CopyMode "ClearSelectionMode",  -- TODO: doesn't work
          }},
        }

        config.key_tables = {
          copy_mode = {
            -- close
            {key = "Escape",      mods = "",      action = wezterm.action.CopyMode "Close"},
            {key = "i",           mods = "",      action = wezterm.action.CopyMode "Close"},
            {key = "a",           mods = "",      action = wezterm.action.CopyMode "Close"},  -- TODO: scroll to the bottom
            {key = "c",           mods = "CTRL",  action = wezterm.action.CopyMode "Close"},
            -- yank
            {key = "y",           mods = "",      action = wezterm.action.Multiple {
              wezterm.action.CopyTo "ClipboardAndPrimarySelection",
              wezterm.action.CopyMode "Close",
            }},
            -- basic motions
            {key = "LeftArrow",   mods = "",      action = wezterm.action.CopyMode "MoveLeft"},
            {key = "RightArrow",  mods = "",      action = wezterm.action.CopyMode "MoveRight"},
            {key = "UpArrow",     mods = "",      action = wezterm.action.CopyMode "MoveUp"},
            {key = "DownArrow",   mods = "",      action = wezterm.action.CopyMode "MoveDown"},
            -- vi motions
            {key = "h",           mods = "",      action = wezterm.action.CopyMode "MoveLeft"},
            {key = "j",           mods = "",      action = wezterm.action.CopyMode "MoveDown"},
            {key = "k",           mods = "",      action = wezterm.action.CopyMode "MoveUp"},
            {key = "l",           mods = "",      action = wezterm.action.CopyMode "MoveRight"},
            {key = "b",           mods = "",      action = wezterm.action.CopyMode "MoveBackwardWord"},
            {key = "w",           mods = "",      action = wezterm.action.CopyMode "MoveForwardWord"},
            {key = "e",           mods = "",      action = wezterm.action.CopyMode "MoveForwardWordEnd"},
            {key = "0",           mods = "",      action = wezterm.action.CopyMode "MoveToStartOfLine"},
            {key = "^",           mods = "SHIFT", action = wezterm.action.CopyMode "MoveToStartOfLineContent"},
            {key = "$",           mods = "SHIFT", action = wezterm.action.CopyMode "MoveToEndOfLineContent"},
            {key = "g",           mods = "SHIFT", action = wezterm.action.CopyMode "MoveToScrollbackBottom"},
            {key = "h",           mods = "SHIFT", action = wezterm.action.CopyMode "MoveToViewportTop"},
            {key = "l",           mods = "SHIFT", action = wezterm.action.CopyMode "MoveToViewportBottom"},
            {key = "m",           mods = "SHIFT", action = wezterm.action.CopyMode "MoveToViewportMiddle"},
            -- simplefied vi motions
            {key = "g",           mods = "",      action = wezterm.action.CopyMode "MoveToScrollbackTop"},
            {key = "d",           mods = "",      action = wezterm.action.CopyMode {MoveByPage = (0.5)}},
            {key = "u",           mods = "",      action = wezterm.action.CopyMode {MoveByPage = (-0.5)}},
            -- vi inline search
            {key = "f",           mods = "",      action = wezterm.action.CopyMode {JumpForward = {prev_char = false}}},
            {key = "t",           mods = "",      action = wezterm.action.CopyMode {JumpForward = {prev_char = true}}},
            {key = "F",           mods = "",      action = wezterm.action.CopyMode {JumpBackward = {prev_char = false}}},
            {key = "T",           mods = "",      action = wezterm.action.CopyMode {JumpBackward = {prev_char = true}}},
            {key = ";",           mods = "",      action = wezterm.action.CopyMode "JumpAgain"},
            {key = ",",           mods = "",      action = wezterm.action.CopyMode "JumpReverse"},
            -- vi selection
            {key = "v",           mods = "",      action = wezterm.action.CopyMode {SetSelectionMode = "Cell"}},
            {key = "v",           mods = "SHIFT", action = wezterm.action.CopyMode {SetSelectionMode = "Line"}},
            {key = "v",           mods = "CTRL",  action = wezterm.action.CopyMode {SetSelectionMode = "Block"}},
            -- gnu readline motions
            {key = "b",           mods = "CTRL",  action = wezterm.action.CopyMode "MoveLeft"},
            {key = "f",           mods = "CTRL",  action = wezterm.action.CopyMode "MoveRight"},
            {key = "n",           mods = "CTRL",  action = wezterm.action.CopyMode "MoveDown"},
            {key = "p",           mods = "CTRL",  action = wezterm.action.CopyMode "MoveUp"},
            {key = "b",           mods = "META",  action = wezterm.action.CopyMode "MoveBackwardWord"},
            {key = "f",           mods = "META",  action = wezterm.action.CopyMode "MoveForwardWord"},
            {key = "a",           mods = "CTRL",  action = wezterm.action.CopyMode "MoveToStartOfLineContent"},
            {key = "e",           mods = "CTRL",  action = wezterm.action.CopyMode "MoveToEndOfLineContent"},
            -- vi search
            {key = "/",           mods = "",      action = wezterm.action.Search {Regex = ""}},
            {key = "?",           mods = "SHIFT", action = wezterm.action.Search {Regex = ""}},
            {key = "n",           mods = "",      action = wezterm.action.Multiple {
              wezterm.action.CopyMode "NextMatch",
              wezterm.action.CopyMode "ClearSelectionMode",
            }},
            {key = "n",           mods = "SHIFT", action = wezterm.action.Multiple {
              wezterm.action.CopyMode "PriorMatch",
              wezterm.action.CopyMode "ClearSelectionMode",
            }},
          },
          search_mode = {
            {key = "Enter",       mods = "",      action = wezterm.action.Multiple {
              wezterm.action.ActivateCopyMode,
              wezterm.action.CopyMode "ClearSelectionMode",
            }},
            {key = "Escape",      mods = "",      action = wezterm.action.Multiple {
              wezterm.action.CopyMode "ClearPattern",
              wezterm.action.CopyMode "Close",
            }},
            {key = "r",           mods = "CTRL",  action = wezterm.action.CopyMode "CycleMatchType"},
            {key = "u",           mods = "CTRL",  action = wezterm.action.CopyMode "ClearPattern"},
          },
        }

        return config
      '';
    };
  };
}
