{
  config,
  lib,
  ...
}: {
  options = {
    modules.kitty.enable = lib.mkEnableOption "kitty";
  };
  config = lib.mkIf config.modules.kitty.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "Hasklug Nerd Font";
        size = 10;
      };
      actionAliases = {
        "launch_scrollback_overlay" = "launch --stdin-source=@screen_scrollback --type=overlay";
      };
      keybindings = {
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
        "ctrl+0" = "change_font_size current 0";
        "ctrl+equal" = "change_font_size current *1.1";
        "ctrl+minus" = "change_font_size current /1.1";
        "ctrl+shift+n" = "new_os_window_with_cwd";
        "ctrl+shift+Space" = "launch_scrollback_overlay nvim -R +";
        "ctrl+shift+alt+Space" = "launch_scrollback_overlay --stdin-add-formatting nvim -R +";
        "ctrl+alt+Space" = "show_scrollback";
      };
      settings = {
        clear_all_shortcuts = true;
        clear_selection_on_clipboard_loss = true;
        confirm_os_window_close = 0;
        disable_ligatures = "cursor";
        scrollback_fill_enlarged_window = true;
        scrollback_lines = 2000;
        scrollback_pager_history_size = 128;
        touch_scroll_multiplier = 10.0;
      };
    };
  };
}
