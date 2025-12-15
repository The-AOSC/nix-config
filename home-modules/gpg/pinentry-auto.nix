{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.modules.gpg.enable {
    programs.fish = {
      functions = {
        "update_pinentry_user_data" = {
          onEvent = "fish_preexec";
          body = ''
            if [ -n "$TMUX" ]
              set -f pid (tmux display-message -p '#{client_pid}')
            else
              set -f pid self
            end
            if tr '\0' '\n' < /proc/$pid/environ | grep -Pq '^(WAYLAND_DISPLAY|DISPLAY)=.'
              set -gx PINENTRY_USER_DATA gui
            else
              set -gx PINENTRY_USER_DATA tty
            end
            # for ssh
            gpg-connect-agent updatestartuptty /bye > /dev/null
          '';
        };
      };
      interactiveShellInit = ''
        update_pinentry_user_data
      '';
    };
    services.gpg-agent.pinentry.package = pkgs.writeShellScriptBin "pinentry-auto" ''
      if [ "$PINENTRY_USER_DATA" = "tty" ]; then
        exec ${lib.getExe pkgs.pinentry-tty} "$@";
      else
        exec ${lib.getExe pkgs.pinentry-qt} "$@";
      fi
    '';
  };
}
