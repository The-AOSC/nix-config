{
  fetchFromGitHub,
  hyprlandPlugins,
  lib,
  meson,
  ninja,
}:
hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "hyprtasking";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "raybbian";
    repo = "hyprtasking";
    rev = "b3e1ae4e48d57fc69a03db73d8dc2496628e6633";
    hash = "sha256-W+WX/oTKSzqdX6zoaIxRyHQv5Jdd/z/6JXR7Da1nfKY=";
  };
  patches = [
    ./001-implement-absolute-navigation.patch
    ./002-reverse-vertical-direction.patch
    ./003-dump-workspaces-map.patch
    ./004-implement-swap-workspaces.patch
  ];
  nativeBuildInputs = [
    meson
    ninja
  ];
  meta = {
    homepage = "https://github.com/raybbian/hyprtasking";
    description = "Powerful workspace management plugin, packed with features";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
}
