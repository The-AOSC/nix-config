{pkgs, ...}: {
  modules.options.screenshot = {
    userPackages = [
      pkgs.slurp  # interactive selection
      pkgs.grim  # capture
    ];
  };
}
