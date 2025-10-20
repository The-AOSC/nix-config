{
  config,
  pkgs,
  lib,
  ...
}: let
  plugin = pkgs.vimPlugins.kitty-scrollback-nvim;
in {
  config = lib.mkIf config.modules.kitty.enable {
    programs.neovim = {
      extraLuaConfig = ''
        require('kitty-scrollback').setup()
      '';
      plugins = [
        {
          plugin = plugin;
          config = ''
          '';
        }
      ];
    };
    programs.kitty = {
      settings = {
        allow_remote_control = lib.mkDefault "socket-only";
        listen_on = ''unix:''${XDG_RUNTIME_DIR}/kitty'';
      };
      actionAliases = {
        "kitty_scrollback_nvim" = "kitten ${plugin}/python/kitty_scrollback_nvim.py";
      };
    };
  };
}
