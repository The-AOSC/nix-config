{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.git.enable = lib.mkEnableOption "git";
  };
  config = lib.mkIf config.modules.git.enable {
    programs.git = {
      enable = true;
      attributes = [
        "*.gz diff=gzip merge=gzip"
      ];
      ignores = [
        "result"
        "tags"
      ];
      signing = {
        signByDefault = true;
        key = null;
      };
      userName = "The AOSC";
      userEmail = "the-aosc@tutamail.com";
      extraConfig = {
        init = {
          defaultBranch = "master";
        };
        core = {
          autocrlf = "input";
        };
        log.showSignature = true;
        push.autoSetupRemote = true;
        pull.ff = "only";
        "diff \"gzip\"" = {
          binary = true;
          textconv = "${pkgs.gzip}/bin/zcat";
        };
        "merge \"gzip\"" = {
          driver = let
            merge-driver = pkgs.writeShellScript "git-gzip-merge-driver" ''
              tmpdir="$(mktemp -d -t tmp.XXXXXXXXXX)"

              function cleanup() {
                  res=$?
                  rm -rf "$tmpdir"
                  exit $res
              }
              trap cleanup EXIT

              ${pkgs.gzip}/bin/zcat "$1" > "$tmpdir/base" || exit 1
              ${pkgs.gzip}/bin/zcat "$2" > "$tmpdir/current" || exit 1
              ${pkgs.gzip}/bin/zcat "$3" > "$tmpdir/other" || exit 1

              ${config.programs.git.package}/bin/git merge-file -L "$5" -L "$4" -L "$6" --marker-size="$7" "$tmpdir/current" "$tmpdir/base" "$tmpdir/other"
              res=$?

              if [ "$res" -gt 127 ]; then
                  exit 1
              fi

              ${pkgs.gzip}/bin/gzip "$tmpdir/current" -c > "$2" || exit 255

              exit "$res"
            '';
          in "${merge-driver} %O %A %B %S %X %Y %L";
          recursive = "binary";
        };
      };
    };
  };
}
