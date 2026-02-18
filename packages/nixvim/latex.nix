{
  pkgs,
  lib,
  ...
}: {
  plugins.vimtex = {
    enable = true;
    settings = {
      view_method = "zathura_simple";
      syntax_enabled = false;
      syntax_conceal_disable = true;
    };
    texlivePackage = pkgs.texliveFull;
  };
  extraFiles."after/ftplugin/tex.lua".text = ''
    vim.api.nvim_buf_set_keymap(0, 'n', '<c-s>', '<plug>(vimtex-view)', {})
  '';
}
