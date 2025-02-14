{...}: {
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [
      "--cmd cd"
    ];
  };
  home.persistence."/persist/storage/home/vladimir" = {
    directories = [
      ".local/share/zoxide"
    ];
  };
}
