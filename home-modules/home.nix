{ pkgs, pkgs-unstable, ... }: {
  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    bat
    binwalk
    bvi
    clang
    dig
    dmenu
    dos2unix
    fastfetch
    feh
    ffmpeg
    file
    gimp
    glxinfo
    gparted
    jq
    killall
    man-pages
    moreutils
    nmap
    pdfarranger
    playerctl
    qpwgraph
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
