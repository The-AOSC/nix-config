{...}: {
  imports = [
    ./colorscheme.nix
    ./neorg.nix
    ./securemodelines.nix
  ];
  viAlias = true;
  vimAlias = true;
  opts = {
    # tabs
    tabstop = 4;
    softtabstop = 0;
    expandtab = true;
    shiftwidth = 4;
    smarttab = true;
    # line numbers
    number = true;
    relativenumber = true;
    # no line wrapping
    wrap = false;
    # show tabs, nb-spaces, trailing spaces as ">", "+" and "-"
    list = true;
    # time until swap update & gitgutter update time
    updatetime = 100;
  };
  highlight."ExtraWhitespace" = {
    ctermbg = "red";
    bg = "red";
  };
  match."ExtraWhitespace" = ''\s\+$'';
  keymaps = [
    {
      mode = "!";
      key = "<C-p>";
      action = "<Up>";
    }
    {
      mode = "!";
      key = "<C-n>";
      action = "<Down>";
    }
    {
      mode = "!";
      key = "<C-b>";
      action = "<Left>";
    }
    {
      mode = "!";
      key = "<C-f>";
      action = "<Right>";
    }
    {
      mode = "i";
      key = "<C-a>";
      action = "<C-O>^";
    }
    {
      mode = "c";
      key = "<C-a>";
      action = "<Home>";
    }
    {
      mode = "!";
      key = "<C-e>";
      action = "<End>";
    }
    {
      mode = "!";
      key = "<C-d>";
      action = "<Del>";
    }
  ];
  autoCmd = [
    # go to the last position in file
    {
      event = "BufReadPost";
      pattern = "*";
      command = ''silent! normal! g`"zv'';
    }
  ];
  plugins.colorizer.enable = true;
  plugins.gitgutter.enable = true;
  plugins.nix.enable = true;
  plugins.treesitter.enable = true;
  plugins.treesitter.highlight.enable = true;
}
