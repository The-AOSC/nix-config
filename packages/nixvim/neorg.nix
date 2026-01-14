{pkgs, ...}: {
  plugins.neorg = {
    enable = true;
    settings.load = {
      "core.defaults" = {
        __empty = true;
      };
      "core.concealer" = {
        __empty = true;
      };
      "core.export" = {
        __empty = true;
      };
    };
    package = pkgs.vimPlugins.neorg.overrideAttrs (old: {
      patches =
        old.patches or []
        ++ [
          (pkgs.fetchpatch2 {
            url = "https://github.com/nvim-neorg/neorg/commit/6208f556719d08dc61db02fde6a877768ecb592a.patch?full_index=1";
            hash = "sha256-9jrFDSZUXwR7X7DJQRggixlV6HSxhbcEpm0rt4nd8EQ=";
          })
          (pkgs.fetchpatch2 {
            url = "https://github.com/nvim-neorg/neorg/commit/a0858f0f83dd45e26671b9153babf974bb52e205.patch?full_index=1";
            hash = "sha256-GIOAXPFZzyRjDfGRLsQlO9Bky2BJ0sY64Vqo0LYJTwo=";
          })
        ];
    });
  };
}
