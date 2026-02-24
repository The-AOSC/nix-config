{
  options,
  config,
  lib,
  ...
}: let
  enable = config.modules.u2f.enable;
in {
  options = {
    modules.u2f.enable = lib.mkEnableOption "u2f";
    # skip keycard check for root (escape hatch)
    security.pam.services = lib.mkOption {
      type = let
        cfg = config;
      in
        with lib.types;
          attrsOf (
            submodule ({config, ...}: {
              options = {
                u2fAuthControl = lib.mkOption {
                  inherit (options.security.pam.u2f.control) type description;
                  default = cfg.security.pam.u2f.control;
                  defaultText = lib.literalExpression "config.security.pam.u2f.control";
                };
              };
              config = lib.mkIf enable {
                /*
                !!!!!!!!!!! WARNING !!!!!!!!!!!
                from nixos source:
                This option and its suboptions are experimental and subject to breaking changes without notice.
                If you use this option in your system configuration, you will need to manually monitor this module for any changes. Otherwise, failure to adjust your configuration properly could lead to you being locked out of your system, or worse, your system could be left wide open to attackers.
                If you share configuration examples that use this option, you MUST include this warning so that users are informed.
                !!!!!!!!!!! WARNING !!!!!!!!!!!
                */
                rules.auth = {
                  # skip keycard check for root
                  rootskipu2f = {
                    enable = true;
                    control = "[success=1 default=ignore]";
                    modulePath = "${cfg.security.pam.package}/lib/security/pam_succeed_if.so";
                    order = config.rules.auth.u2f.order - 1;
                    args = lib.mkAfter ["uid" "eq" "0"]; # root has uid 0
                    settings = {
                      quiet = true;
                    };
                  };
                  u2f.control = lib.mkForce config.u2fAuthControl;
                };
              };
            })
          );
    };
  };
  config = lib.mkIf enable {
    # https://github.com/NixOS/nixpkgs/pull/486044
    systemd = lib.mkIf config.security.polkit.enable {
      services."polkit-agent-helper@".serviceConfig = {
        PrivateDevices = lib.mkForce false;
        DeviceAllow = [
          "/dev/urandom r"
          "char-hidraw rw"
        ];
        ProtectHome = lib.mkForce "read-only";
        StandardError = "journal";
      };
    };
    security.pam = {
      u2f = {
        enable = true;
        control = "required"; # multi factor by default
        settings = {
          # pamu2fcfg -o pam://security-key > u2f-keys
          authfile = "${./u2f-keys}"; # NOTE: string interpolation needed to remove reference to source flake
          cue = true;
          origin = "pam://security-key";
        };
      };
      services = {
        "doas".u2fAuthControl = "sufficient";
        "polkit-1".u2fAuthControl = "sufficient";
        "sshd".u2fAuth = false;
      };
    };
  };
}
