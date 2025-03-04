{pkgs, ...}: {
  home.packages = [
    pkgs.endgame-singularity
  ];
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".config/singularity"
      ".local/share/singularity"
    ];
  };
}
