{pkgs, ...}: {
  modules.options.unp = {
    userPackages = [
      pkgs.unp
      (pkgs.unrar-free.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ../../patches/unrar-free/remove-free-suffix.patch
        ];
      }))
      pkgs.p7zip
    ];
  };
}
