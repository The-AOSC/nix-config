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
    pciutils
    pdfarranger
    playerctl
    qpwgraph
    qrencode
    rlwrap
    rsync
    screen
    shellcheck
    strace
    termdown
    traceroute
    translate-shell
    tty-solitaire
    universal-ctags
    unixtools.xxd
    usbutils
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
      "migration"
    ];
    files = [
    ];
    allowOther = false;
  };
}
