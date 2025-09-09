{
  config,
  lib,
  ...
}: {
  options = {
    modules.u2f.enable = lib.mkEnableOption "u2f";
  };
  config = lib.mkIf config.modules.u2f.enable {
    security.pam = {
      u2f = {
        enable = true;
        # pamu2fcfg -o pam://security-key > u2f-keys
        settings = {
          authfile = "${./u2f-keys}"; # NOTE: string interpolation needed to remove reference to source flake
          cue = true;
          origin = "pam://security-key";
        };
      };
      # multi factor on login for everyone but root
      services = let
        serviceConfig = name: let
          cfg = config.security.pam.services."${name}";
        in {
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
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              order = cfg.rules.auth.u2f.order - 1;
              args = lib.mkAfter ["uid" "eq" "0"]; # root has uid 0
              settings = {
                quiet = true;
              };
            };
            # others have to provide keycard
            u2f = {
              control = lib.mkForce "required";
            };
          };
        };
      in {
        hyprlock = serviceConfig "swaylock";
        login = serviceConfig "login";
        swaylock = serviceConfig "swaylock";
        vlock = serviceConfig "swaylock";
      };
    };
  };
}
