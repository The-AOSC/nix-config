{osConfig, config, pkgs, lib, ...}: let
  fileSystemsWhitelist = ["/" "/nix"];
  fileSystemsBlacklist = lib.filter (name: !(builtins.elem name fileSystemsWhitelist)) (lib.mapAttrsToList (name: value: name) osConfig.fileSystems);
  firejailBlacklist = lib.concatMapStringsSep " " (path: "--blacklist=${path}") fileSystemsBlacklist;
  location = "Desktop/games";
in {
  home.packages = [
    pkgs.wineWowPackages.staging
    pkgs.winetricks
  ];
  home.file."${location}/firejail-run.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      dir="$1"
      shift
      exec firejail --profile=wine ${firejailBlacklist} --private="$dir" -- "$@"
    '';
  };
  home.file."${location}/firejail-run-cwd.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ -d ".wine" ]; then
          exec ${config.home.file."${location}/firejail-run.sh".source} . "$@"
      else
          echo "Error: missing .wine"
          exit 1
      fi
    '';
  };
  home.file."${location}/winecfg.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec ${config.home.file."${location}/firejail-run-cwd.sh".source} winecfg "$@"
    '';
  };
  home.file."${location}/winetricks.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec ${config.home.file."${location}/firejail-run-cwd.sh".source} winetricks --force "$@"
    '';
  };
  home.file."${location}/init.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ $# -ge 1 ]; then
          dir="$1"
      elif echo "$0" | grep -qz '^../'; then
          dir="$(pwd)"
      else
          echo "Error: bad location"
          exit 1
      fi

      if [ $# -ge 2 ]; then
          home="$2"
      else
          home="home"
      fi

      if [ $# -ge 3 ]; then
          run="$3"
      else
          run="run.sh"
      fi

      echo dir: "$dir"
      echo home: "$home"
      echo run: "$run"

      mkdir -p "$dir"
      if [ ! -e "$dir/$run" ]; then
          cat > "$dir/$run" << EOF2
      #!/bin/sh

      exec ${config.home.homeDirectory}/${location}/firejail-run.sh "$(realpath "$dir")/$home" \\
      sh << EOF
      cd .
      #export DXVK_HUD=1
      exec wine explorer
      EOF
      EOF2
          chmod +x "$dir/$run"
      fi

      mkdir -p "$dir/$home"
      if [ ! -d "$dir/$home/.wine" ]; then
          ${config.home.file."${location}/firejail-run.sh".source} "$dir/$home" winetricks --force -q dlls dxvk vcrun2022 #vkd3d
      fi
    '';
  };
}
