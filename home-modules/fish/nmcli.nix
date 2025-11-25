{
  config,
  lib,
  ...
}: {
  programs.fish.completions = lib.mkIf config.modules.fish.enable {
    nmcli = ''
      function __fish_complete_nmcli
        nmcli --complete-args (commandline -cx)[2..] (commandline -ct)
      end
      complete -c nmcli -kfa "(__fish_complete_nmcli)"
    '';
  };
}
