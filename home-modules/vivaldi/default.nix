{pkgs, ...}: {
  home.packages = [
    pkgs.vivaldi
  ];
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".config/vivaldi"
      ".local/lib/vivaldi"
    ];
    files = [
      ".local/share/.vivaldi_reporting_data"
    ];
  };
}
