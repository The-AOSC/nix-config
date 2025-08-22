{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./darkreader
    ./global.nix
    ./lib.nix
    ./profile-files.nix
    ./simple-tab-groups
    ./tree-style-tabs
    ./vimium
  ];
  options = {
    modules.librewolf = {
      enable = lib.mkEnableOption "librewolf";
      globalConfig = lib.mkOption {
        type = with lib.types; coercedTo attrs lib.singleton (listOf attrs);
        description = "Config shared between profiles";
      };
    };
  };
  config = lib.mkIf config.modules.librewolf.enable {
    catppuccin.librewolf.force = true;
    programs.librewolf = {
      enable = true;
      package = pkgs.librewolf.overrideAttrs (old: {
        # https://github.com/nilcons/firefox-hacks
        patches = [
          ./keybindings.patch
        ];
        buildCommand = ''
          ${old.buildCommand or ""}
          mkdir /build/browser-omni.ja
          cd /build/browser-omni.ja
          ${pkgs.unzip}/bin/unzip $out/lib/librewolf/browser/omni.ja || true
          rm $out/lib/librewolf/browser/omni.ja
          cd /build
          source $stdenv/setup
          patchPhase
          cd /build/browser-omni.ja
          ${pkgs.zip}/bin/zip $out/lib/librewolf/browser/omni.ja -0DXr -- *
        '';
      });
      policies = {
        DisableAccounts = true;
        DisableFirefoxAccounts = true;
        DisableTelemetry = true;
        ExtensionUpdate = false;
      };
      profiles = lib.mapAttrs (name: profileConfig: lib.mkMerge (config.modules.librewolf.globalConfig ++ [profileConfig])) {
        default = {
          settings = {
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          };
        };
        private = {
          id = 1;
          settings = {
            "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
            "privacy.clearOnShutdown_v2.cache" = true;
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
            "privacy.clearOnShutdown_v2.formdata" = true;
            "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
            "privacy.clearOnShutdown_v2.siteSettings" = true;
          };
        };
        tor = {
          id = 2;
          settings = {
            "network.proxy.socks" = "localhost";
            "network.proxy.socks_port" = osConfig.services.tor.client.socksListenAddress.port;
            "network.proxy.type" = 1;
            "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
            "privacy.clearOnShutdown_v2.cache" = true;
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
            "privacy.clearOnShutdown_v2.formdata" = true;
            "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
            "privacy.clearOnShutdown_v2.siteSettings" = true;
          };
        };
      };
    };
    home.persistence."/persist" = {
      directories = [
        ".librewolf/default"
      ];
    };
  };
}
