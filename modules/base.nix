{inputs, ...}: {
  flake-file.inputs.disko.url = "github:nix-community/disko";
  flake-file.inputs.impermanence.url = "github:nix-community/impermanence";
  flake.aspects = {aspects, ...}: {
    base = {
      includes = [
        aspects.direnv
        aspects.secrets
      ];
      nixos = {
        pkgs,
        lib,
        ...
      }: {
        imports = [
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
        ];
        environment.persistence."/persist" = {
          enable = true;
          directories = [
            "/var/lib/nixos"
            "/var/log/journal"
          ];
          files = [
            "/etc/machine-id"
          ];
        };
        networking = {
          networkmanager.enable = true;
          firewall = {
            enable = true;
            allowPing = true;
          };
          nftables.enable = true;
        };
        users.mutableUsers = false;
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        programs.fish.enable = true;
        programs.nano.enable = false;
        programs.neovim.enable = true;
        environment.binsh = lib.getExe pkgs.dash;
        systemd.tmpfiles.rules = [
          "D! /persist/tmp 0755 root root"
        ];
        nix.channel.enable = false;
        nix.settings = {
          auto-optimise-store = true;
          build-dir = "/persist/tmp";
          experimental-features = ["nix-command" "flakes"];
          keep-derivations = true;
          keep-failed = true;
          keep-going = true;
          keep-outputs = true;
        };
        environment.systemPackages = with pkgs; [
          git
          inetutils
          (lib.hiPrio unixtools.hostname)
          (lib.hiPrio unixtools.ping)
        ];
      };
      homeManager = {
        osConfig,
        config,
        lib,
        ...
      }: {
        home.stateVersion = osConfig.system.stateVersion;
        programs.home-manager.enable = true;
        home.activation.removeChannels = lib.hm.dag.entryAfter ["writeBoundary"] ''
          rm -rf ${config.home.homeDirectory}/.nix-defexpr
          rm -rf ${config.home.homeDirectory}/.nix-profile
        '';
      };
    };
  };
}
