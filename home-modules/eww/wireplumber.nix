{pkgs, ...}: let
  wireplumber-info = pkgs.writeShellScript "wireplumber-info" ''
    set -e -o pipefail
    sink="$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)"
    source="$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@)"
    out="$(printf '[%f,"%s",%f,"%s"]' "$(echo "$sink"|cut -d' ' -f2)" "$(echo "$sink"|cut -d' ' -f3)" "$(echo "$source"|cut -d' ' -f2)" "$(echo "$source"|cut -d' ' -f3)")" || out="[]"
    echo "$out"
  '';
in {
  modules.eww.config = ''
    (defpoll wireplumber :interval "1s"
                         :initial '[]'
      "${wireplumber-info}")
  '';
}
