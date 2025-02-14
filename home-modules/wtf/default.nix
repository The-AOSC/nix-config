{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "wtf" ''
      exec -a "$0" ${pkgs.wtf}/bin/wtf -o "$@"
    '')
  ];
  programs.fish.interactiveShellInit = ''
    export ACRONYMDB="${./acronyms} ${pkgs.wtf}/share/misc/acronyms ${pkgs.wtf}/share/misc/acronyms-o.real ${pkgs.wtf}/share/misc/acronyms.comp"
    alias wtf='wtf -o'
  '';
}
