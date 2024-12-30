{ pkgs, pkgs-unstable, ... }: {
  home.username = "vladimir";
  home.homeDirectory = "/home/vladimir";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    bat
    bvi
    clang
    dig
    dos2unix
    fastfetch
    feh
    ffmpeg
    file
    gimp
    glxinfo
    jq
    killall
    man-pages
    moreutils
    nmap
    pdfarranger
    playerctl
    qrencode
    rlwrap
    rsync
    shellcheck
    strace
    termdown
    traceroute
    translate-shell
    tty-solitaire
    universal-ctags
    unixtools.xxd
    ventoy-full
    vlock
    wev
    wget
    wl-clipboard
    yt-dlp
    zathura
    zip
  ];
  home.persistence."/persist/system/home/vladimir" = {
    enable = true;
    directories = [
    ];
    files = [
    ];
    allowOther = false;
  };
  home.persistence."/persist/storage/home/vladimir" = {
    enable = true;
    directories = [
    ];
    files = [
    ];
    allowOther = false;
  };
}
