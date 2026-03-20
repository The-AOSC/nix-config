let
  module = {
    self,
    config,
    lib,
    ...
  }: let
    cfg = config.auto-follow;
    lockJson = builtins.fromJSON (builtins.readFile cfg.lockFile);
    root = resolveLockReference lockJson.root;
    # resolve flake.lock input reference (`["nixvim" "systems"]` or `"nixpkgs"`)
    # to it's value (`{inputs=...; locked=...; original=...;}`)
    resolveLockReference = reference:
      if (builtins.isString reference)
      then lockJson.nodes.${reference}
      else resolveLockListReference root.inputs reference;
    resolveLockListReference = context: reference: let
      tail = builtins.tail reference;
      res = resolveLockReference context.${builtins.head reference};
      ctx = res.inputs;
    in
      if reference == [] # handle `follows = ""`
      then {}
      else if tail == []
      then res
      else resolveLockListReference ctx tail;
    # convert flake.lock input reference to valid follows entry value
    # (`["nixvim" "systems"]` -> `"nixvim/systems"`)
    mkFollows = reference:
      if builtins.isString reference
      then reference
      else builtins.concatStringsSep "/" reference;
    # walk over inputs dependency graph in a BFS manner and construct following values for every node:
    # info - input value (`{inputs=...; locked=...; original=...;}`)
    # name - node name (`"nixpkgs"`, `"nixpkgs-lib"`, `"home-manager"`, etc)
    # reference - flake.lock reference value that would point to this node (`["flake-parts" "nixpkgs-lib"]`)
    # followsReference - follows entry value to reference this node (`"flake-parts/nixpkgs-lib"`)
    flattenInfo = location: parent:
      (lib.converge ({
          children,
          parents,
        }: let
          newChildren = lib.concatMap ({
            location,
            parent,
          }:
            lib.mapAttrsToList (
              name: ref: rec {
                inherit name;
                reference = location ++ [name];
                followsReference = mkFollows reference;
                info = assert lib.assertMsg (reference != ref) "auto-follow: reference ${mkFollows reference} resolves to itself";
                assert lib.assertMsg ((resolveLockReference reference) == (resolveLockReference ref)) "auto-follow: reference ${mkFollows ([lockJson.root] ++ reference)} doesn't resolves to ${mkFollows ref}";
                  resolveLockReference ref;
              }
            ) (parent.inputs or {}))
          parents;
        in {
          children = children ++ newChildren;
          parents =
            lib.map (child: {
              location = child.reference;
              parent = child.info;
            })
            newChildren;
        }) {
          children = [];
          parents = [{inherit location parent;}];
        }).children;
    flatInfo = lib.filter (value: value.info != {}) (flattenInfo [] root);
    # check if input values (`{inputs=...; locked=...; original=...;}`) is the same flake
    sameSource = a: b: let
      filterSource = v: let
        lowerAttrs = list: attrs:
          attrs
          // (lib.mapAttrs (n: v:
            if lib.elem n list
            then lib.toLower v
            else v)
          attrs);
        src =
          v
          // {
            locked = lowerAttrs ["owner" "repo"] (builtins.removeAttrs v.locked ["ref" "rev" "lastModified" "narHash"]);
          }
          // {
            original = lowerAttrs ["owner" "repo"] (builtins.removeAttrs v.original ["ref" "rev"]);
          };
      in
        src;
      a' = filterSource a;
      b' = filterSource b;
    in
      (a'.locked == b'.locked) || (lib.any (inputs: lib.all (src: lib.any (lib.flip lib.matchAttrs src) inputs) [a' b']) cfg.simularInputs);
    # calculate flake-file.inputs follows entries
    inputsConfig =
      lib.imap0 (i: value: let
        prev = lib.take i flatInfo;
        ref = lib.findFirst (v: (value.name == v.name) && (sameSource value.info v.info)) null prev;
        configPath = (lib.init (lib.concatMap (v: [v "inputs"]) value.reference)) ++ ["follows"];
      in {
        inherit i value ref configPath;
        config =
          if ref != null
          then lib.setAttrByPath configPath ref.followsReference
          else {};
      })
      flatInfo;
  in {
    options.auto-follow = {
      enable = lib.mkEnableOption "auto-follow";
      lockFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to flake.lock file";
        example = lib.literalExpression "../flake.lock";
        default = self + /flake.lock;
      };
      simularInputs = lib.mkOption {
        type = with lib.types; listOf (listOf attrs);
        description = "Flake references to be considered interchangeable";
        example = lib.literalExpression ''
          [
            [
              {
                original.owner = "nixos";
                original.repo = "flake-compat";
                original.type = "github";
              }
              {
                original.type = "tarball";
                original.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
              }
            ]
          ]
        '';
        default = [];
      };
    };
    config = {
      flake-file.inputs = lib.mkMerge (lib.map (v: v.config) inputsConfig);
    };
  };
in {
  flake.flakeModules.auto-follow = {lib, ...}: {
    imports = [module];
    auto-follow.enable = lib.mkDefault true;
  };
  imports = [module];
}
