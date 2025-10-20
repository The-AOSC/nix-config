{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.char-names.enable = lib.mkEnableOption "char-names";
  };
  config = lib.mkIf config.modules.char-names.enable {
    home.packages = [
      (pkgs.writeScriptBin "char-names" ''
        #!${pkgs.sbcl}/bin/sbcl --script

        (require :uiop)

        (dolist (string (uiop/image:command-line-arguments))
          (map nil #'(lambda (char)
                       (format t "~0@*~c    ~20<(~1@*~a)~;(#x~1@*~x)~;~>~2@*~a~%"
                               char (char-code char) (char-name char)))
               string))
      '')
    ];
  };
}
