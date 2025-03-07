{pkgs, ...}: {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ../../patches/swaylock/swaylock-1.8.0-revert-drop-support-for-layer-shell.patch
        ];
    });
    settings = {
      color = "3f3f3f";
      show-failed-attempts = true;
      ignore-empty-password = true;
    };
  };
}
