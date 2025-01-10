{...}: {
  modules.options.htop = {
    persist.system.config.files = [
      "/etc/htoprc"
    ];
  };
}
