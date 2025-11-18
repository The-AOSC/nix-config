{
  jq,
  writeShellApplication,
  writeShellScript,
  writeText,
  ...
}:
writeShellApplication {
  name = "nix-flake-add-roots";
  runtimeInputs = [
    jq
  ];
  text = let
    jqFilter = writeText "nix-flake-add-roots-jq-filter" ''
      [
        # add name for parent flake
        {root:.}
        # filter all flakes (format: {"$name":{"path":"$path"},...})
        | .. | select(.[]?.path?)
        # change format to: {"name":"$name","path":"$path"}
        | to_entries | map({name:.key,path:.value.path})[]
      ]
      | unique_by(.path)
      # output stream of pairs: "$name", "$path"
      | map([.name,.path])[][]
    '';
    linkRoot = writeShellScript "nix-flake-add-roots-link-root" ''
      name=".flake-roots/$1"
      path="$2"
      suffix=
      if [ -e "$name" ]; then
        suffix=2
        while [ -e "$name-$suffix" ]; do
          suffix="$(($suffix + 1))"
        done
        name="$name-$suffix"
      fi
      nix-store --realise --add-root "$name" "$path"
    '';
  in ''
    nix flake prefetch-inputs
    rm -rf .flake-roots
    mkdir .flake-roots
    nix flake archive --dry-run --json \
      | jq -r -f ${jqFilter} \
      | xargs --max-args 2 --max-procs=1 ${linkRoot}
  '';
}
