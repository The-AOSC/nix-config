{pkgs, ...}: {
  home.packages = [
    pkgs.hunspell
    pkgs.hunspellDicts.en_US-large
    pkgs.hunspellDicts.ru_RU
    (pkgs.writeShellScriptBin "rlspell" ''
      exec ${pkgs.rlwrap}/bin/rlwrap ${pkgs.hunspell}/bin/hunspell "$@"
    '')
  ];
}
