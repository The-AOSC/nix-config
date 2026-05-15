{
  flake-file.inputs = {
    nixvirt.url = "github:AshleyYakeley/NixVirt";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      inputs.ndg.follows = "";
    };
    nur.url = "github:nix-community/NUR";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin-vimium = {
      url = "github:/catppuccin/vimium";
      flake = false;
    };
    nix-gaming.url = "github:fufexan/nix-gaming";
    nom.url = "github:maralorn/nix-output-monitor";
    nix-monitored.url = "github:ners/nix-monitored";
    ez-configs.url = "github:ehllie/ez-configs";
    lan-mouse.url = "github:feschber/lan-mouse";
    nixvim.url = "github:nix-community/nixvim";
  };
}
