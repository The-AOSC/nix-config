{
  config,
  lib,
  ...
}: {
  programs.fish = lib.mkIf config.modules.fish.enable {
    functions = {
      # nom likes to cut long lines, which sometimes cuts of hyperlink terminator
      "terminate_hyperlinks" = {
        onEvent = "fish_postexec";
        body = ''
          printf '\e]8;;\e\\'
        '';
      };
    };
    interactiveShellInit = ''
      type -q "terminate_hyperlinks"
    '';
  };
}
