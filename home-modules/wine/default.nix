{
  inputs,
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
    wine-staging = pkgs.wine-staging-fixed;
    wine-ge = pkgs.wine-ge-fixed;
    with-wine-ge = pkgs.writeShellScriptBin "with-wine-ge" ''
      PATH=${wine-ge}/bin:$PATH
      exec "$@"
    '';
  in
    lib.mkIf config.modules.wine.enable {
      home.packages = [
        pkgs.winetricks
        wine-staging
        with-wine-ge
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
      home.checks = let
        timeout = 600;
        test-wine = wine:
          pkgs.testers.runNixOSTest {
            name = "${wine.name}";
            nodes.machine = {pkgs, ...}: {
              environment.systemPackages = [
                wine
              ];
            };
            testScript = let
              hello32 = "${pkgs.pkgsCross.mingw32.hello}/bin/hello.exe";
              hello64 = "${pkgs.pkgsCross.mingwW64.hello}/bin/hello.exe";
            in ''
              TIMEOUT = ${builtins.toString timeout}
              machine.wait_for_unit("multi-user.target")
              ${lib.concatMapStrings (hello: ''
                output = machine.succeed("wine ${hello}", timeout=TIMEOUT)
                assert "Hello, world!" in output
              '') [hello32 hello64]}
            '';
          };
        test-wine-graphical = wine:
          pkgs.testers.runNixOSTest {
            name = "${wine.name}-graphical";
            nodes.machine = {pkgs, ...}: {
              imports = [
                "${inputs.nixpkgs}/nixos/tests/common/x11.nix"
              ];
              environment.systemPackages = [
                wine
              ];
            };
            testScript = let
              hello32 = "${pkgs.pkgsCross.mingw32.hello}/bin/hello.exe";
              hello64 = "${pkgs.pkgsCross.mingwW64.hello}/bin/hello.exe";
            in ''
              TIMEOUT = ${builtins.toString timeout}
              machine.wait_for_x()
              ${lib.concatMapStrings (hello: let
                hello-bat = pkgs.writeText "hello.bat" ''
                  ${lib.replaceString "/" "\\" hello} > hello-output
                '';
              in ''
                machine.succeed("wineconsole ${hello-bat}", timeout=TIMEOUT)
                machine.wait_for_file("hello-output")
                output = machine.succeed("cat hello-output", timeout=TIMEOUT)
                assert "Hello, world!" in output
                output = machine.succeed("rm hello-output", timeout=TIMEOUT)
              '') [hello32 hello64]}
              machine.succeed("mkdir directory-name", timeout=TIMEOUT)
              machine.execute("wine explorer directory-name >/dev/null &")
              machine.wait_for_window("directory-name")
            '';
          };
        test-with-wine-ge = pkgs.testers.runNixOSTest {
          name = "with-wine-ge";
          nodes.machine = {pkgs, ...}: {
            environment.systemPackages = [
              wine-staging
              with-wine-ge
            ];
          };
          testScript = let
          in ''
            machine.wait_for_unit("multi-user.target")
            wine_path = machine.succeed("realpath $(which wine)")
            wine_ge_path = machine.succeed("realpath $(with-wine-ge which wine)")
            wine_path_expected = machine.succeed("realpath ${wine-staging}/bin/wine")
            wine_ge_path_expected = machine.succeed("realpath ${wine-ge}/bin/wine")
            print(f"{wine_path=}")
            print(f"{wine_ge_path=}")
            print(f"{wine_path_expected=}")
            print(f"{wine_ge_path_expected=}")
            assert wine_path == wine_path_expected
            assert wine_ge_path == wine_ge_path_expected
          '';
        };
      in [
        (test-wine-graphical wine-ge)
        (test-wine-graphical wine-staging)
        (test-wine wine-ge)
        (test-wine wine-staging)
        test-with-wine-ge
      ];
    };
}
