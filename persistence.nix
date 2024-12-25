{...}: {
  # for configs, non specific to particular machine, things that generaly don't change
  environment.persistence."/persist/system" = {
    enable = true;
    hideMounts = true;
    directories = [
    ];
    files = [
    ];
  };
  # for personal files, dynamically updated files
  environment.persistence."/persist/storage" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/log/journal"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
