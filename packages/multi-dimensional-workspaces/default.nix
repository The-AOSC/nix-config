{
  mkHyprlandPlugin,
  hyprland,
  lib,
  ...
}:
mkHyprlandPlugin {
  pluginName = "multi-dimensional-workspaces";
  version = "1.0";
  src = ./src;
  meta = {
    description = "Hyprland plugin that aranges workspaces as a multi-dimensional array";
    platforms = lib.platforms.linux;
  };
}
