{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.neovim = lib.mkIf config.modules.neovim.enable {
    extraLuaConfig = ''
      require("colorizer").setup()
    '';
    plugins = with pkgs.vimPlugins; [
      nvim-colorizer-lua
    ];
  };
}
