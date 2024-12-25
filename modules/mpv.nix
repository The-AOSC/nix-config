{pkgs, ...}: {
  modules.options.mpv = {
    userPackages = [
      # old version
      #/*
      ((pkgs.wrapMpv (pkgs.mpv-unwrapped.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ./patches/mpv/mpv-0.35.1-always-never-osd-cycle.patch
          ./patches/mpv/mpv-0.35.1-cut-chapter-list.patch
        ];
      })) {
        scripts = [
          pkgs.mpvScripts.mpris
        ];
      }))
      #*/
      # new version
      /*
      ((pkgs.mpv-unwrapped.wrapper {
        mpv =  pkgs.mpv-unwrapped.overrideAttrs (old: {
          patches = (old.patches or []) ++ [
            ./patches/mpv/mpv-0.35.1-always-never-osd-cycle.patch
            ./patches/mpv/mpv-0.35.1-cut-chapter-list.patch
          ];
        });
        scripts = [
          pkgs.mpvScripts.mpris
        ];
      }))
      */
    ];
    persist.user.config.files = [
      ".config/mpv/input.conf"
      ".config/mpv/mpv.conf"
      ".config/mpv/script-opts/osc.conf"
      ".config/mpv/scripts/change-OSD-media-title.lua"
    ];
    persist.user.data.directories = [
      ".local/state/mpv/watch_later"
    ];
  };
}
