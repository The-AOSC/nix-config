{pkgs, ...}: {
  home.packages = [
    pkgs.libreoffice
  ];
  home.persistence."/persist/storage/home/vladimir" = {
    directories = [
      ".config/libreoffice"
    ];
  };
}
