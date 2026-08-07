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
    rev = "a3efa15ada7318daa6fcf55c361dd7bdef15df3e";
    hash = "sha256-KCJM6c+XRUO9VWP9KUUWJCMxxSPaiWMZNMOdnO0x3vk=";
  };
  patches = [
    ./update-for-v0.56.1.patch
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
