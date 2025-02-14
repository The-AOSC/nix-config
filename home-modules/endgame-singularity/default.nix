{pkgs, ...}: {
  home.packages = [
    pkgs.endgame-singularity
  ];
  home.persistence."/persist/system/home/vladimir" = {
    directories = [
      ".config/singularity"
    ];
  };
  home.persistence."/persist/storage/home/vladimir" = {
    directories = [
      ".local/share/singularity"
    ];
  };
}
