{pkgs, ...}: {
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
      "8FEA1239D48FB852123025D0FCFA4475EDCF4912"  # gpg --list-keys --with-keygrip
    ];
    pinentryPackage = pkgs.pinentry-qt;
  };
  home.persistence."/persist/storage/home/vladimir" = {
    directories = [
      ".gnupg/private-keys-v1.d"
    ];
  };
}
