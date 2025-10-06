{
  writeShellApplication,
  jq,
  ...
}:
writeShellApplication {
  name = "nix-flake-add-roots";
  runtimeInputs = [
    jq
  ];
  text = ''
    rm -rf .flake-roots
    mkdir .flake-roots
    nix flake archive --dry-run --json \
      | jq '..|.path?|strings' \
      | xargs --max-procs=1 \
      nix-store --realise --add-root .flake-roots/root
  '';
}
