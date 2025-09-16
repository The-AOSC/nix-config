{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.wine.enable = lib.mkEnableOption "wine";
  };
  config = let
    fileSystemsWhitelist = ["/" "/nix"];
    fileSystemsBlacklist = lib.filter (name: !(builtins.elem name fileSystemsWhitelist)) (lib.mapAttrsToList (name: value: name) osConfig.fileSystems);
    firejailBlacklist = lib.concatMapStringsSep " " (path: "--blacklist=${path}") fileSystemsBlacklist;
    location = "Desktop/games";
  in
    lib.mkIf config.modules.wine.enable {
      home.packages = with pkgs; [
        (pkgs.writeShellScriptBin "with-wine-ge" ''
          PATH=${pkgs.wine-ge-fixed}/bin:$PATH
          exec "$@"
        '')
        wine-staging-fixed
        winetricks
      ];
      home.file = {
        "${location}/firejail-run.sh" = {
          executable = true;
          text = ''
            #!/bin/sh
            dir="$1"
            shift
            exec firejail --profile=wine ${firejailBlacklist} --disable-mnt --private="$dir" -- "$@"
          '';
        };
        "${location}/firejail-run-cwd.sh" = {
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
        "${location}/winecfg.sh" = {
          executable = true;
          text = ''
            #!/bin/sh
            exec ${config.home.file."${location}/firejail-run-cwd.sh".source} winecfg "$@"
          '';
        };
        "${location}/winetricks.sh" = {
          executable = true;
          text = ''
            #!/bin/sh
            ${config.home.file."${location}/firejail-run-cwd.sh".source} winetricks --force "$@" 2>&1 | grep --color=auto -i 'warning\|$'
          '';
        };
        "${location}/init.sh" = {
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
            set -e
            #export DXVK_HUD=1
            exec wine start explorer
            EOF
            EOF2
                chmod +x "$dir/$run"
            fi

            mkdir -p "$dir/$home"
            if [ ! -d "$dir/$home/.wine" ]; then
                cd "$dir/$home"
                mkdir .wine
                #${config.home.homeDirectory}/${location}/firejail-run.sh "$dir/$home" ${pkgs.wineprefix-preparer}/bin/wineprefix-preparer
                ${config.home.file."${location}/winetricks.sh".source} -q dlls dxvk vcrun2022 #vkd3d
                ${config.home.file."${location}/winetricks.sh".source} vd=1920x1080
            fi
          '';
        };
      };
    };
}
