{pkgs, ...}: let
  network-listener = pkgs.writeShellScript "network-listener" ''
    set -e -o pipefail
    nmcli monitor | while read line; do
      sleep 1
      interface="$(ip route show default | grep -Po '(?<=\bdev )[^ ]+' | head -n1 || true)"
      if [ -n "$interface" ]; then
        connection="$(nmcli -t device status | grep "^$interface:" | head -n1 | cut -d: -f4 || true)"
      else
        connection=""
      fi
      if [ -n "$connection" ]; then
        type="$(nmcli -t connection show "$connection" | grep -Po '(?<=^connection.type:).+$' | head -n1 || true)"
      else
        type=""
      fi
      printf '{"interface":"%s","connection":"%s","type":"%s"}\n' "$interface" "$connection" "$type"
    done
  '';
in {
  modules.eww.config = ''
    (deflisten network :initial '{"interface":"","connection":"","type":""}'
      "${network-listener}")
  '';
}
