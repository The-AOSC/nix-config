{...}: {
  modules.options.endgame-singularity = {
    persist.user.config.directories = [
      ".config/singularity"
    ];
    persist.user.data.directories = [
      ".local/share/singularity"
    ];
  };
}
