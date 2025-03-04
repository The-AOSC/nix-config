{pkgs, ...}: {
  imports = [
    ./base.nix
    ./kdeconnect
    ../packages/wtf.nix
    ./wine
  ];
  nix.settings.allowed-users = ["@wheel"];
  hardware.graphics.enable = true;
  users.mutableUsers = false;
  users.users.root.hashedPasswordFile = "/etc/credentials/root.hashedpassword";
  security.doas = {
    enable = true;
    extraRules = [
      {
        keepEnv = true;
        setEnv = [
          "-XDG_CACHE_HOME"
        ];
        groups = [
          "wheel"
        ];
      }
      {
        keepEnv = true;
        setEnv = [
          "-XDG_CACHE_HOME"
          "SUDO_UID=$EUID"
        ];
        groups = [
          "wheel"
        ];
        cmd = "nixos-rebuild";
      }
    ];
  };
  programs.fuse.userAllowOther = true;
  services.logind = {
    hibernateKey = "ignore";
    lidSwitch = "ignore";
    powerKey = "ignore";
    rebootKey = "ignore";
    suspendKey = "ignore";
  };
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  boot.kernel.sysctl."kernel.dmesg_restrict" = 0;
}
