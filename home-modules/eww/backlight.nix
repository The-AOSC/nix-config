{pkgs, ...}: {
  modules.eww.config = ''
    (defpoll backlight :interval "1s"
                       :initial "100"
      "${pkgs.brightnessctl}/bin/brightnessctl -m|cut -d , -f 4|tr -d %")
  '';
}
