{pkgs, ...}: {
  modules.options.python = {
    userPackages = [
      (pkgs.python3.withPackages (python-packages: with python-packages; [
        sh
      ]))
    ];
  };
}
