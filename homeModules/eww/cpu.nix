{pkgs, ...}: let
  cpu-usage-listener = pkgs.writeShellScript "cpu-usage-listener" ''
    set -e -o pipefail
    stats=($(head -n1 /proc/stat | jq -R '[scan("[0-9]+")|tonumber]|.[3]+.[4],add'))
    stats_idle_prev=''${stats[0]}
    stats_total_prev=''${stats[1]}
    while true; do
      sleep 2
      stats=($(head -n1 /proc/stat | jq -R '[scan("[0-9]+")|tonumber]|.[3]+.[4],add'))
      stats_idle=''${stats[0]}
      stats_total=''${stats[1]}
      echo $((100 - (100*($stats_idle-$stats_idle_prev))/($stats_total-$stats_total_prev)))
      stats_idle_prev=$stats_idle
      stats_total_prev=$stats_total
    done
  '';
in {
  modules.eww.config = ''
    (deflisten cpu-usage :initial 0
      "${cpu-usage-listener}")
  '';
}
