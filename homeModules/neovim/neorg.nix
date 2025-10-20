{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.neovim = lib.mkIf config.modules.neovim.enable {
    extraLuaConfig = ''
      require("neorg").setup {
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {},
          ["core.export"] = {},
        },
      }
      require("nvim-treesitter.configs").setup {
        highlight = {
          enable = true,
        },
      }
    '';
    plugins = with pkgs.vimPlugins; [
      neorg
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
    ];
  };
}
