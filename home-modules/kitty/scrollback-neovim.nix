{
  config,
  pkgs,
  lib,
  ...
}: let
  vim = config.modules.neovim.package;
  integration = config.modules.neovim.enable && (lib.attrByPath ["config" "plugins" "kitty-scrollback" "enable"] false vim);
  plugin = vim.config.plugins.kitty-scrollback.package;
in {
  config = lib.mkIf config.modules.kitty.enable {
    programs.kitty = {
      settings = {
        allow_remote_control = lib.mkDefault "socket-only";
        listen_on = ''unix:''${XDG_RUNTIME_DIR}/kitty'';
      };
      actionAliases = lib.mkIf integration {
        "kitty_scrollback_nvim" = "kitten ${plugin}/python/kitty_scrollback_nvim.py";
      };
    };
  };
}
