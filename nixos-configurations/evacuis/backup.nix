{
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
      #paths = lib.uniqueStrings (system-paths ++ home-paths);
      paths = ["/persist"];
    in
      paths;
    environment = {
      "BORG_RSH" = let
        key = (lib.elemAt (lib.filter (key: key.type == "rsa") config.services.openssh.hostKeys) 0).path;
      in "${lib.getExe config.services.openssh.package} -i ${key}";
      "BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK" = "1";
    };
    repo = "ssh://borg@vestigia.local/backup/backup";
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
      hostNames = ["vestigia.local"];
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnLm/0GCVn7Bw0HDDjjwejf1fMyemxMmAVY/MVC2oKa0toWCGx2HChbL0EBbQLokX6DGb7NkBRkmtCldIzBCT1/zT8xASJXdjhuOWBmo2MqoBAoMHb6gAyBHgy9g8UmiZ8hpdnYMs8BUk3prjKXKp75sQeH+z8ckp1vgLSeNllxRuWGxswmRJ9Ow1qXmVePxMEyIjx3fWEUH6RFKYVTOUzFn6mtRrYjFHBh+Znjpa7f3hlJlINBXWXcgpmCqjZVBDTcHaG5QheCJFsussHq56ciN8m/bodLNRShOpfbYmKyqdYPdTHg1YKqCFXN+w3VugQ94/hwE8aa2+gyvXthJomKYcW9uSPUvYt8Gxp58sGF+W5PmfcBwGSWynrdvFdYkMySH/jTFWYREM8kNzs6RHijAJLOftTjR+3mTsDDmP/Ewdyis/oQSS9ec8FBcXNxNOpDW+kr3+xBLrt0zou+9nvvjrSRFL5COVAwuC4EIsTzbIgJp74qHEL9ZDgweGqFMO/vnCEgAUu2WVdpWkEQP1NN+0JzdgFHLWJXGJher6ceAGzCUT+pZpjDTfLddsC6L9NBPpxKf5JMMlItSZ1OqQDzRPnUMdGi5T8NZtHO4tS4zUx678AW9ZDkuycS0OgoydeQ2QOXYN0qFZejomoJiA3Fb87644BqEZmtXS/m5VaqQ==";
    };
    "vestigia/ed25519" = {
      hostNames = ["vestigia.local"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhpBSfn12pVZJw3wAe96GH9uRuvTTbE0veFDnIRfzE3";
    };
  };
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/systemd/timers"
    ];
  };
}
