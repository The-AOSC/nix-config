{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.translate-shell.enable = lib.mkEnableOption "translate-shell";
  };
  config = lib.mkIf config.modules.translate-shell.enable {
    home.packages = with pkgs; [
      translate-shell-https
      (pkgs.runCommand "translate-shell-wrappers" {} ''
        mkdir -p $out/bin/
        ${lib.concatMapAttrsStringSep "\n" (name: value: ''
            cat > $out/bin/${name} << EOF
            #!${pkgs.runtimeShell}
            exec ${pkgs.translate-shell-https}/bin/trans ${value} "\$@"
            EOF
            chmod +x $out/bin/${name}
          '') (lib.concatMapAttrs (name: value: {
              "${name}" = "-j -b ${value}";
              "${name}v" = "-j ${value}";
              "${name}d" = "-b ${value}";
              "${name}vd" = "${value}";
            }) {
              transe = "en:ru";
              transr = "ru:en";
              transer = "ru:en";
              transa = ":ru";
              transae = ":en";
            })}
      '')
      (pkgs.runCommand "translate-shell-wrappers" {} ''
        mkdir -p $out/bin/
        ${lib.concatMapAttrsStringSep "\n" (name: value: ''
            cat > $out/bin/${name} << EOF
            #!${pkgs.runtimeShell}
            exec ${pkgs.translate-shell}/bin/trans ${value} "\$@"
            EOF
            chmod +x $out/bin/${name}
          '') (lib.concatMapAttrs (name: value: {
              "u${name}" = "-j -b ${value}";
              "u${name}v" = "-j ${value}";
              "u${name}d" = "-b ${value}";
              "u${name}vd" = "${value}";
            }) {
              transe = "en:ru";
              transr = "ru:en";
              transer = "ru:en";
              transa = ":ru";
              transae = ":en";
            })}
      '')
    ];
  };
}
