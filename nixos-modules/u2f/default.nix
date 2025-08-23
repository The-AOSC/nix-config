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
      # don't allow to login using only keycard
      services.login.u2fAuth = false;
      services.swaylock.u2fAuth = false;
    };
  };
}
