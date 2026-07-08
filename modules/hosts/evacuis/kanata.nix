{
  config,
  den,
  ...
}: {
  den.hosts.x86_64-linux.evacuis.kanata.keyboards."default" = config.lib.kanata.layouts.full;
  den.aspects.evacuis.includes = [
    den.aspects.glide
  ];
}
