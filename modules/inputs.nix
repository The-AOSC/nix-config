{
  flake-file.inputs = {
    # https://flakehub.com/flake/AshleyYakeley/NixVirt
    nixvirt.url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      inputs.ndg.follows = "";
    };
    files.url = "github:mightyiam/files";
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
