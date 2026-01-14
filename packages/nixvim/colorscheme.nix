{...}: {
  colorscheme = "catppuccin";
  colorschemes.catppuccin = {
    enable = true;
    settings.flavour = "mocha";
  };
  highlightOverride = {
    "DiffAdd".fg = "LightGreen";
    "DiffChange".fg = "Yellow";
    "DiffDelete".fg = "Red";
    "LineNr".fg = "Yellow";
  };
}
