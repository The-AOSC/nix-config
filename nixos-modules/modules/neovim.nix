{config, pkgs, ...}: {
  modules.options.neovim = {
    userPackages = [];
    persist.user.data.directories = [
      ".local/state/nvim"
    ];
  };
  programs.neovim = config.modules.lib.withModuleUsersConfig "neovim" {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = ''
          set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
          set number relativenumber
          set nowrap

          " highlight trailing spaces
          highlight ExtraWhitespace ctermbg=red guibg=red
          match ExtraWhitespace /\s\+$/

          " show tabs, nb-spaces, trailing spaces as ">", "+" and "-"
          set list

          map! <C-p> <Up>
          map! <C-n> <Down>
          map! <C-b> <Left>
          map! <C-f> <Right>
          imap <C-a> <C-O>^
          cmap <C-a> <Home>
          map! <C-e> <End>
          map! <C-d> <Del>
          " default
          "map! <C-h> <BS>

          " go to last position in file
          autocmd BufReadPost * silent! normal! g`"zv

          " securemodelines config
          let g:secure_modelines_allowed_items = [
                      \ "textwidth",   "tw",
                      \ "softtabstop", "sts",
                      \ "tabstop",     "ts",
                      \ "shiftwidth",  "sw",
                      \ "expandtab",   "et",   "noexpandtab", "noet",
                      \ "filetype",    "ft",
                      \ "foldmethod",  "fdm",
                      \ "readonly",    "ro",   "noreadonly", "noro",
                      \ "rightleft",   "rl",   "norightleft", "norl",
                      \ "wrap",        "nowrap"
                      \ ]
          "lua << EOF
          "  require("neorg").setup {
          "  }
          "EOF
      '';
      packages.package = with pkgs.vimPlugins; {
        start = [
          vim-nix
          securemodelines
          #neorg
        ];
      };
    };
  };
  programs.nano.enable = config.modules.lib.withModuleUsersConfig "neovim" false;
}
