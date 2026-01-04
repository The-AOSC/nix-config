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
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          local status, result
          status, result = pcall(vim.treesitter.start)
          if status then
            --vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          elseif not string.match(result, "Parser could not be created for buffer .* and language ") then
            error(result)
          end
        end,
      })
    '';
    plugins = with pkgs.vimPlugins; [
      (neorg.overrideAttrs (old: {
        patches =
          old.patches or []
          ++ [
            (pkgs.fetchpatch2 {
              url = "https://github.com/nvim-neorg/neorg/commit/6208f556719d08dc61db02fde6a877768ecb592a.patch?full_index=1";
              hash = "sha256-9jrFDSZUXwR7X7DJQRggixlV6HSxhbcEpm0rt4nd8EQ=";
            })
            (pkgs.fetchpatch2 {
              url = "https://github.com/nvim-neorg/neorg/commit/a0858f0f83dd45e26671b9153babf974bb52e205.patch?full_index=1";
              hash = "sha256-GIOAXPFZzyRjDfGRLsQlO9Bky2BJ0sY64Vqo0LYJTwo=";
            })
          ];
      }))
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
    ];
  };
}
