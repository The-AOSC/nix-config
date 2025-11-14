{
  nixos-anywhere,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "nixos-anywhere-install-for";
  runtimeInputs = [
    nixos-anywhere
  ];
  text = ''
    if [ $# -lt 2 ]; then
      printf "Usage: %s HOST IP [NIXOS-ANYWHERE-OPTS]..." "$0"
      exit 1
    fi
    host="$1"
    ip="$2"
    shift 2
    nixos-anywhere --generate-hardware-config nixos-generate-config ./hosts/"$host"/hardware-configuration.nix --flake ".#$host" --target-host root@"$ip" "$@"
    nix fmt ./hosts/"$host"/hardware-configuration.nix
  '';
}
