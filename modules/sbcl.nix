{pkgs, ...}: {
  modules.options.sbcl = {
    userPackages = [
      (pkgs.sbcl.withPackages (subpkgs: with subpkgs; [
        cffi
        parse-float
      ]))
    ];
    persist.user.config.files = [
      ".sbclrc"
    ];
  };
}
