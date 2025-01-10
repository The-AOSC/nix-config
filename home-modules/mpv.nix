{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    package = pkgs.mpv-unwrapped.wrapper {
      mpv = pkgs.mpv-unwrapped.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ../patches/mpv/mpv-0.35.1-always-never-osd-cycle.patch
          ../patches/mpv/mpv-0.35.1-cut-chapter-list.patch
        ];
      });
      scripts = [
        pkgs.mpvScripts.mpris
      ];
    };
    bindings = {
      "Shift+F8" = "show-text \${chapter-list}";
      "DEL" = "script-binding osc/visibility-no-auto";  # see mpv-0.35.1-always-never-osd-cycle.patch
      "Shift+KP9" = "add chapter 1";
      "Shift+KP3" = "add chapter -1";
      "Shift+q" = "quit";
      "q" = "quit-watch-later";
      "Alt+KP_ADD" = "add video-zoom 0.1";
      "Alt+KP_SUBTRACT" = "add video-zoom -0.1";
    };
    config = {
      no-sub-visibility = "";
      hwdec = "auto-safe";
    };
    scriptOpts = {
      osc = {
        visibility = "never";
      };
    };
  };
  xdg.configFile."change-OSD-media-title.lua" = {
    target = "mpv/scripts/change-OSD-media-title.lua";
    text = ''
      local options = require 'mp.options'

      local o = {
          filename_override = "",  -- mpv ... --script-opts=change-OSD-media-title-filename_override="..."
      }

      options.read_options(o, "change-OSD-media-title", nil)
      --opt.read_options(user_opts, "change-OSD-media-title", function(list) update_options(list) end)

      local name = ""

      function set_osd_title()
          local chapter = ""

          if name == "" then
              name = mp.get_property_osd("media-title")
          end

          if o.filename_override ~= "" then
              name = o.filename_override
          end

          if mp.get_property_osd("chapter") ~= "" then
              chapter = " • Chapter: " .. mp.get_property_osd("chapter")
          end

          mp.set_property("force-media-title", name .. chapter)
      end

      mp.observe_property("chapter", "string", set_osd_title)
    '';
  };
  home.persistence."/persist/storage/home/vladimir" = {
    directories = [
      ".local/state/mpv/watch_later"
    ];
  };
}
