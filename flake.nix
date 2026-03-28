# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "NixOS configuration of The AOSC";

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-vimium = {
      url = "github:/catppuccin/vimium";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        flake-parts = {
          follows = "flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };
        nixpkgs.follows = "nixpkgs";
      };
    };
    files.url = "github:mightyiam/files";
    flake-aspects.url = "github:vic/flake-aspects";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        home-manager = {
          follows = "home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        nixpkgs.follows = "nixpkgs";
      };
    };
    import-tree.url = "github:vic/import-tree";
    lan-mouse = {
      url = "github:feschber/lan-mouse";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
      };
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        flake-parts = {
          follows = "flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };
        git-hooks.inputs = {
          flake-compat.follows = "nix-mineral/flake-compat";
          gitignore.inputs.nixpkgs.follows = "nixpkgs";
          nixpkgs.follows = "nixpkgs";
        };
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      inputs = {
        flake-parts = {
          follows = "flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };
        ndg.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.follows = "nixpkgs";
    nixpkgs-nixvim.url = "github:nixos/nixpkgs?rev=ce0546f43cf747ef8f232a204569be9b7771b375";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        flake-parts = {
          follows = "flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };
        nixpkgs.follows = "nixpkgs-nixvim";
      };
    };
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nom = {
      url = "github:maralorn/nix-output-monitor";
      inputs = {
        flake-utils.inputs.systems.follows = "nixvim/systems";
        git-hooks = {
          follows = "nix-gaming/git-hooks";
          inputs = {
            flake-compat.follows = "nix-mineral/flake-compat";
            gitignore = {
              follows = "nix-gaming/git-hooks/gitignore";
              inputs.nixpkgs.follows = "nixpkgs";
            };
            nixpkgs.follows = "nixpkgs";
          };
        };
        nixpkgs.follows = "nixpkgs";
      };
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        flake-parts = {
          follows = "flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };
        nixpkgs.follows = "nixpkgs";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
