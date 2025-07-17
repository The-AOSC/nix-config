{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
  ];
  options = {
    modules.desktop.enable = lib.mkEnableOption "desktop";
  };
  config = lib.mkIf config.modules.desktop.enable {
    modules.cava.enable = true;
    modules.char-names.enable = true;
    modules.endgame-singularity.enable = true;
    modules.ffprobe-duration.enable = true;
    modules.fish.enable = true;
    modules.fonts.enable = true;
    modules.git.enable = true;
    modules.gpg.enable = true;
    modules.htop.enable = true;
    modules.hunspell.enable = true;
    modules.kdeconnect.enable = true;
    modules.libreoffice.enable = true;
    modules.mako.enable = true;
    modules.mpv.enable = true;
    modules.neovim.enable = true;
    modules.nix-sh.enable = true;
    modules.pass.enable = true;
    modules.powerctl.enable = true;
    modules.qbittorrent.enable = true;
    modules.qtile.enable = true;
    modules.sbcl.enable = true;
    modules.ssh.enable = true;
    modules.textwrap.enable = true;
    modules.tmux.enable = true;
    modules.translate-shell.enable = true;
    modules.unp.enable = true;
    modules.vivaldi.enable = true;
    modules.wezterm.enable = true;
    modules.wine.enable = true;
    modules.wmenu-history.enable = true;
    modules.wtf.enable = true;
    modules.zoxide.enable = true;
    home.persistence."/persist" = {
      directories = [
        ".local/state/wireplumber"
      ];
    };
    home.packages = with pkgs; [
      bat
      brightnessctl
      bvi
      dig
      dos2unix
      fastfetch
      feh
      ffmpeg
      file
      gimp
      grim
      helvum
      imagemagick
      inetutils
      jmtpfs
      jq
      killall
      man-pages
      moreutils
      nmap
      pciutils
      pdfarranger
      pipes
      pulseaudio # pactl
      rlwrap
      screen
      shellcheck
      sops
      speedtest-cli
      termdown
      tree
      tty-solitaire
      universal-ctags
      unixtools.xxd
      usbutils
      wev
      wget
      wl-clipboard
      yt-dlp
      zathura
    ];
  };
}
