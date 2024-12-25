{...}: {
  modules.options.tor-browser = {
    persist.user.data.directories = [
      ".tor project"
    ];
  };
}
