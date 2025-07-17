{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./neorg.nix
  ];
  options = {
    modules.neovim.enable = lib.mkEnableOption "neovim";
  };
  config = lib.mkIf config.modules.neovim.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      extraConfig = ''
        set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
        set number relativenumber
        set nowrap

        " use terminal color scheme
        set notermguicolors
        color vim

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
      '';
      extraLuaConfig = ''
        loadfile("${./colorscheme.lua}")()
      '';
      plugins = with pkgs.vimPlugins; [
        {
          plugin = securemodelines;
          config = ''
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
          '';
        }
        {
          plugin = vim-gitgutter;
          config = ''
            set updatetime=100
          '';
        }
        vim-nix
      ];
    };
    home.sessionVariables = {
      MANPAGER = "${config.programs.neovim.finalPackage}/bin/nvim +Man!";
    };
    home.packages = [
      (pkgs.writeShellScriptBin "view" ''
        exec -a "$0" ${config.programs.neovim.finalPackage}/bin/nvim -R "$@"
      '')
    ];
    home.persistence."/persist" = {
      directories = [
        ".local/state/nvim"
      ];
    };
  };
}
