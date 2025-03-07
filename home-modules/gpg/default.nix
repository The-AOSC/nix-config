{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.gpg = {
    enable = true;
    mutableKeys = false;
    mutableTrust = false;
    publicKeys = [
      {
        source = ./The-AOSC.pubkeys;
        trust = "ultimate";
      }
    ];
  };
  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    enableSshSupport = true;
    sshKeys = [
      "8FEA1239D48FB852123025D0FCFA4475EDCF4912" # gpg --list-keys --with-keygrip
    ];
    pinentryPackage = pkgs.pinentry-qt;
  };
  home.activation = {
    force-private-gpg = lib.hm.dag.entryAfter ["writeBoundary" "createAndMountPersistentStoragePaths"] ''
      run chmod -077 ${config.home.homeDirectory}/.gnupg
      run chmod -077 /persist/home/aosc/.gnupg
      run chmod -077 /persist/home/aosc/.gnupg/private-keys-v1.d
    '';
  };
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".gnupg/private-keys-v1.d"
    ];
  };
}
