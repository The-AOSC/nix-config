{pkgs, ...}: {
  modules.options.libreoffice = {
    userPackages = [
      pkgs.libreoffice
      pkgs.hunspell
      pkgs.hunspellDicts.en_US
      pkgs.hunspellDicts.en_US-large
      pkgs.hunspellDicts.ru_RU
    ];
    persist.user.data.directories = [
      # TODO: some parts might go into user.config
      ".config/libreoffice"
    ];
  };
}
