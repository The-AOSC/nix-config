{pkgs, ...}: {
  home.packages = [
    pkgs.libreoffice
  ];
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".config/libreoffice"
    ];
  };
}
