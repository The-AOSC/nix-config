{...}: let
  color = "blue";
  sec = 1000;
  min = 60 * sec;
  hour = 60 * min;
  day = 24 * hour;
in {
  programs.fish = {
    interactiveShellInit = ''
      set fish_command_timer_enabled 0
      set fish_command_timer_millis 0
      function fish_command_timer_postexec2 -e fish_postexec
        if [ 60000 -le "$CMD_DURATION" ]
          set -l num_days (math -s0 "$CMD_DURATION / ${builtins.toString day}")
          set -l num_hours (math -s0 "$CMD_DURATION % ${builtins.toString day} / ${builtins.toString hour}")
          set -l num_mins (math -s0 "$CMD_DURATION % ${builtins.toString hour} / ${builtins.toString min}")
          set -l num_secs (math -s0 "$CMD_DURATION % ${builtins.toString min} / ${builtins.toString sec}")
          set -l cmd_duration_str ""
          if [ $num_days -gt 0 ]
            set cmd_duration_str {$cmd_duration_str}{$num_days}"d "
          end
          if [ $num_hours -gt 0 ]
            set cmd_duration_str {$cmd_duration_str}{$num_hours}"h "
          end
          if [ $num_mins -gt 0 ]
            set cmd_duration_str {$cmd_duration_str}{$num_mins}"m "
          end
          set cmd_duration_str {$cmd_duration_str}{$num_secs}"s"
          set -l timing_str "[ $cmd_duration_str ]"
          set -l output_length (math (string length "$timing_str"))
          echo -ne "\033["{$COLUMNS}"C"
          echo -ne "\033["{$output_length}"D"
          set_color ${color}; echo $timing_str; set color normal
        end
      end
    '';
  };
}
