{
  config,
  pkgs,
  lib,
  ...
}: let
  battery-info = pkgs.writeShellScript "battery-info" ''
    set -e -o pipefail
    cd /sys/class/power_supply
    for name in *; do
      current_now="0"
      capacity="0"
      status=""
      remaining="-:--"
      if [ -f "$name/charge_now" ] && [ -f "$name/charge_full" ]; then
        charge_now="$(cat $name/charge_now)"
        charge_full="$(cat $name/charge_full)"
        if [ -f "$name/current_now" ]; then
          current_now="$(cat $name/current_now)"
        fi
        if [ -f "$name/status" ]; then
          status="$(cat $name/status)"
        fi
        if [ "$current_now" -ne 0 ]; then
          if [ "$status" = "Charging" ]; then
            mins=$((60*($charge_full-$charge_now)/$current_now))
            remaining="$(printf '%d:%02d' $(($mins/60)) $(($mins%60)))"
          elif [ "$status" = "Discharging" ]; then
            mins=$((60*$charge_now/$current_now))
            remaining="$(printf '%d:%02d' $(($mins/60)) $(($mins%60)))"
          fi
        fi
        if [ "$charge_full" -ne 0 ]; then
          capacity="$(${pkgs.bc}/bin/dc <<< "5 k $charge_now $charge_full / p")"
        fi
        printf '["%s", {"status":"%s","remaining":"%s","capacity":%f}]\n' "$name" "$status" "$remaining" "$capacity"
      elif [ -f "$name/status" ]; then
        status="$(cat $name/status)"
        printf '["%s", {"status":"%s","remaining":"%s","capacity":%f}]\n' "$name" "$status" "$remaining" "$capacity"
      fi
    done | ${pkgs.jq}/bin/jq -s 'map({key:.[0],value:.[1]})|from_entries'
  '';
in {
  modules.eww.config = ''
    (defpoll battery-info :initial "{}"
                          :interval "2s"
      "${battery-info}")
  '';
}
