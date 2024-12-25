{pkgs, ...}: {
  modules.options.ventoy = {
    userPackages = [
      pkgs.ventoy-full
    ];
  };
}
