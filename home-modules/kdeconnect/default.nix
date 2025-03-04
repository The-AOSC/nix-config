{pkgs, ...}: {
  home.packages = [
    pkgs.kdePackages.kdeconnect-kde
  ];
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".config/kdeconnect"
    ];
  };
}
