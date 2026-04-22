{
  flake.aspects.hosts._.evacuis.nixos = {
    config,
    lib,
    ...
  }: {
    services.borgbackup.jobs.backup = {
      paths = let
        system-paths = lib.attrNames config.environment.persistence;
        home-paths = lib.concatAttrValues (
          lib.mapAttrs
          (_: conf: lib.attrNames conf.home.persistence)
          (config.home-manager.users or {})
        );
        paths = lib.uniqueStrings (system-paths ++ home-paths);
      in
        paths;
      exclude = [
        "/media/data-fixed"
        "/media/data-raw"
        "/media/home/aosc/Desktop/games"
        "/media/home/aosc/Desktop/Movies"
        "/media/home/aosc/Desktop/Videos/current/90/*.*"
        "/media/home/aosc/Desktop/Videos/current/90/tmp"
        "/media/mnt"
        "/media/sda6"
        "/persist/swap"
        "/persist/tmp"
      ];
      environment = {
        "BORG_RSH" = let
          key = (lib.elemAt (lib.filter (key: key.type == "rsa") config.services.openssh.hostKeys) 0).path;
        in "${lib.getExe config.services.openssh.package} -i ${key}";
        "BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK" = "1";
      };
      repo = "ssh://borg@vestigia/backup/backup";
      compression = "auto,lzma";
      encryption.mode = "none";
      startAt = "daily";
      persistentTimer = true;
      doInit = false;
      prune.keep = {
        within = "1d";
        daily = 2;
        weekly = 2;
        monthly = -1;
      };
    };
    programs.ssh.knownHosts = {
      "vestigia/rsa" = {
        hostNames = ["vestigia"];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyJ9H0/Oo+1ZC8KaR/TI7V+tRz39UOx0ij/lkwG5dr7xyCImofsaj+fzk7CDLamiU7nkVm9eC1U8PmmLSJVimeJ30yK6/i6x69XxET1X5tkbr5gLd4LYoX2+FtCV5HshNTVXeV06g4ejFtaxyDn4LvpGmEosCUejdxlLy/kCd7ZrBG+aFGzRMiCUCwHR4nWFE9NdZLAmwcRmwldHsp0ZhzY4rOjdrwf4/p1N2ctB1N0raH5gudQYOitQkvkRNntE1rjbF4FM5zZmi+DO3fjzI1ge8FJRpWUfMIrTses+GKXT/fpizRcdKSPdf/umgIoQBBWjYTFh0SP/+dvLepgITkxsZ22BGrvLQdiYJqzL7UbQj3fiim59FpGt2voKA4qsuJK0uarSPnYhC8HNaqkUujhZv5iADozWofk79k8FdR61L+1NXyf1NB7aVGur9KcNTrdfTm45X3S/VVjUBMTp6FIh8O8YhUq2g5JbmzUTyORhJPfhLHEKQMhtf1RUuZoolZzmAzt1+U/PAc0RrAiRGlLUV52SCdcQb/FBkvx/AI4Jtqv8mQ+311XEM0/uaOfhBZvlyd/3p2xwLdhimMG1zmVBY26z/+a/2O0VbwH329C6mTp/xX1DapbRWp6ofCQkdiQsm3/Mg27BUJw3fn407FXGwUryGcV2oBHpiUosBbRw==";
      };
      "vestigia/ed25519" = {
        hostNames = ["vestigia"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIEmXQ7td4T+AYHoNQSkPpAElfP4uxmLDvsufvKphfoJ";
      };
    };
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/systemd/timers"
      ];
    };
  };
}
