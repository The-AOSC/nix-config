{pkgs, ...}: {
  modules.options.xxd = {
    userPackages = [
      pkgs.unixtools.xxd
    ];
  };
}
