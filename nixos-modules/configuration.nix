{config, lib, pkgs, ...}: {
  imports = [
    ./modules
    ./packages/wtf.nix
  ];

  hardware.graphics.extraPackages = [
    #pkgs.nvidia-vaapi-driver
    pkgs.intel-media-driver
  ];

  environment.systemPackages = [
    pkgs.git  # TODO: needed?
  ];

  fileSystems."/".options = ["mode=755"];
  fileSystems."/persist".neededForBoot = true;
  #fileSystems."/etc/nixos".neededForBoot = true;
  fileSystems."/etc/credentials".neededForBoot = true;

  modules.users.vladimir.modules = {
    doas.enable = true;
    mako.enable = true;
    qtile.enable = true;
    audio.enable = true;
    cava.enable = true;
    wireshark.enable = true;
    screenshot.enable = true;
    wine.enable = true;
    gnupg.enable = true;
    endgame-singularity.enable = true;
    vivaldi.enable = true;
    users.enable = true;
    libreoffice.enable = true;
    python.enable = true;
    networking.enable = true;
    qbittorrent.enable = true;
    sbcl.enable = true;
    samba.enable = true;
    sway.enable = true;
    kdeconnect.enable = true;
    sshd.enable = true;
    unp.enable = true;
    wtf.enable = true;
    zoxide.enable = true;
    htop.enable = true;
  };
  modules.modules = {
    allow-unfree.enable = true;
    ignore-power-keys.enable = true;
    tmux.enable = true;
    dbus-broker.enable = true;
    fonts.enable = true;
    no-default-packages.enable = true;
    binsh-dash.enable = true;
    offline-rebuild.enable = true;
    users.enable = true;
    systemd-boot.enable = true;
    sysrq.enable = true;
    ntp.enable = true;
    doas.enable = true;
    networking = {
      enable = true;
      hostName = "ASUSLaptop";
    };
    sshd = {
      enable = true;
      ports = [7132];
    };
    htop.enable = true;
    ssh = {
      enable = true;
      knownHosts = {
        github-ed25519 = {
          hostNames = ["github.com"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
        github-ecdsa = {
          hostNames = ["github.com"];
          publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
        };
        github-rsa = {
          hostNames = ["github.com"];
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
        };
      };
    };
  };

  programs.nano.enable = false;
  programs.neovim.enable = true;
  programs.fish.enable = true;
  users.users.vladimir.shell = pkgs.fish;

  programs.firejail.enable = true;

  boot.kernel.sysctl."kernel.dmesg_restrict" = 0;

  # TODO: migration
  fileSystems."/home/vladimir/gentoo/home".device = "/dev/sda11";
  users.groups."fix" = {gid=1001;members=["vladimir"];};
  environment.localBinInPath = true;
  # TODO: is this necessary?
  users.users.vladimir.extraGroups = ["input"];
  services.syncthing = {};  # TODO

  # old to storage migration
  fileSystems."/old-home".device = "/dev/sda11";
  fileSystems."/old-home".neededForBoot = true;
  fileSystems."/persist/storage/home/vladimir/Desktop/Movies".device = "/old-home/vladimir/Desktop/Movies";
  fileSystems."/persist/storage/home/vladimir/Desktop/Movies".fsType = "none";
  fileSystems."/persist/storage/home/vladimir/Desktop/Movies".options = ["bind"];
  fileSystems."/persist/storage/home/vladimir/Desktop/Movies".neededForBoot = true;
  fileSystems."/persist/storage/home/vladimir/Desktop/games".device = "/old-home/wineuser/games";
  fileSystems."/persist/storage/home/vladimir/Desktop/games".fsType = "none";
  fileSystems."/persist/storage/home/vladimir/Desktop/games".options = ["bind"];
  fileSystems."/persist/storage/home/vladimir/Desktop/games".neededForBoot = true;

  # Set your time zone.
  time.timeZone = "Asia/Yekaterinburg";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    # font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  environment.persistence."/persist/system".users.vladimir = {
    directories = [
      ".config/xkb"
      ".local/chromium-extensions"
      ".local/HyperSpec"
      "lsfs"
    ];
    files = [
      ".local/bin/char-names"
      ".local/bin/ffprobe-duration"
      ".local/bin/nix-sh"
      ".local/bin/powerctl"
      ".local/bin/syslog-log"
      ".local/bin/wmenu-history"
    ];
  };
  environment.persistence."/persist/storage".users.vladimir = {
    directories = [
      "Desktop/games"
      "Desktop/Movies"
      "Desktop/Music"
      "nixpkgs"
      "nix-config"
    ];
    # NOTE: doesn't work well with dynamically updated files
    files = [
      ".local/share/wmenu-history.dat"
      "TODO"
    ];
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
