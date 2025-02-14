{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "textwrap" ''
      width=80

      TEMP=$(getopt -o "n:" -n "$0" -- "$@")

      if [ $? -ne 0 ]; then
          exit 1
      fi

      eval set -- "$TEMP"
      unset TEMP

      while true; do
          case "$1" in
              '-n')
                  width="$2"
                  shift 2
                  continue
                  ;;
              '--')
                  shift
                  break
                  ;;
              *)
                  echo 'Internal error!' >&2
                  exit 1
                  ;;
          esac
      done

      grep --color=never -Eo ".{1,$width}([[:blank:]]+|\$)|[^[:blank:]]{$width}" -- "$@" | sed "s/[[:blank:]]*\$//"
    '')
  ];
}
