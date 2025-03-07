{pkgs, ...}: {
  imports = [
    ./cava
    ./char-names
    ./endgame-singularity
    ./ffprobe-duration
    ./fish
    ./fonts
    ./git
    ./gpg
    ./htop
    ./hunspell
    ./kdeconnect
    ./libreoffice
    ./mako
    ./mpv
    ./neovim
    ./nix-sh
    ./pass
    ./powerctl
    ./qbittorrent
    ./qtile
    ./sbcl
    ./ssh
    ./textwrap
    ./tmux
    ./unp
    ./vivaldi
    ./wezterm
    ./wine
    ./wmenu-history
    ./wtf
    ./zoxide
  ];
  home.persistence."/persist/home/aosc" = {
    allowOther = true;
    directories = [
      ".local/state/wireplumber"
    ];
  };
  home.packages = with pkgs; [
    bat
    brightnessctl
    bvi
    dos2unix
    fastfetch
    feh
    ffmpeg
    file
    gimp
    helvum
    imagemagick
    jmtpfs
    jq
    killall
    man-pages
    moreutils
    nmap
    pciutils
    pulseaudio # pactl
    rlwrap
    screen
    shellcheck
    termdown
    translate-shell
    tty-solitaire
    universal-ctags
    usbutils
    wev
    wget
    wl-clipboard
    yt-dlp
    zathura
  ];
}
