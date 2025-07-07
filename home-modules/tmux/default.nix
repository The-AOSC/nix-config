{
  config,
  lib,
  ...
}: {
  options = {
    modules.tmux.enable = lib.mkEnableOption "tmux";
  };
  config = lib.mkIf config.modules.tmux.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      newSession = true;
    };
  };
}
