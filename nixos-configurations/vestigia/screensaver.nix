{
  config,
  pkgs,
  lib,
  ...
}: {
  systemd.services."getty@".restartIfChanged = lib.mkForce true; # can't seem to override for specific instance only
  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = lib.mkBefore [""]; # override default from `getty@.service`
    script = ''
      if [ `date +'%m.%d_%H:%M'` '>' 12.25_00:00 ] || [ `date +'%m.%d_%H:%M'` '<' 01.01_12:00 ]; then
        ${lib.getExe' pkgs.kbd "setfont"} -d
        exec ${lib.getExe pkgs.christbashtree}
      else
        ${lib.getExe' pkgs.kbd "setfont"}
        exec ${lib.getExe pkgs.asciiquarium-transparent} -t
      fi
    '';
  };
  services.cron = {
    enable = true;
    systemCronJobs = [
      ''05 00 25 dec * root systemctl restart getty@tty1''
      ''05 12 01 jan * root systemctl restart getty@tty1''
    ];
  };
}
