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
  };
}
