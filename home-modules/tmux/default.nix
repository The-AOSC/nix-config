{
  config,
  pkgs,
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
      sensibleOnTop = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = battery;
          extraConfig = ''
            set -g status-right '${lib.concatStrings [
              # pane title
              "#{?window_bigger,"
              "[#{window_offset_x}#,#{window_offset_y}] ,}"
              "\"#{=21:pane_title}\"|"
              # battery indicator
              "#{battery_percentage} #{battery_remain}|"
              # date and time
              "%y/%m.%d(%u) %H:%M:%S"
            ]}'
            set -g status-right-length '80'
          '';
        }
      ];
      extraConfig = ''
      '';
    };
    home.packages = with pkgs; [
      acpi # battery plugin
    ];
  };
}
