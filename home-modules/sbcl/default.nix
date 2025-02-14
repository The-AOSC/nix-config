{pkgs, ...}: {
  home.packages = let
    package = pkgs.sbcl.withPackages (subpkgs: with subpkgs; [
      cffi
      parse-float
    ]);
  in [
    package
    (pkgs.writeShellScriptBin "rlcl" ''
      exec ${pkgs.rlwrap}/bin/rlwrap --break-chars "()|\\\`\'\",@;" --multi-line --quote-characters \"\| ${package}/bin/sbcl "$@"
    '')
  ];
  home.file.".sbclrc".source = ./sbclrc.lisp;
}
