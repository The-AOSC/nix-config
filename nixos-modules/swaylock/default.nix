{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.swaylock.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ../../patches/swaylock/swaylock-1.8.0-revert-drop-support-for-layer-shell.patch
        ];
    }))
  ];
  security.pam.services.swaylock = {};
}
