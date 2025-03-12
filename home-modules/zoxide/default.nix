{...}: {
  programs.zoxide = {
    enable = true;
    options = [
      "--cmd cd"
    ];
  };
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".local/share/zoxide"
    ];
  };
}
