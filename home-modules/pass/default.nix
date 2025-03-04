{config, pkgs, ...}: {
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [
      exts.pass-otp
    ]);
    settings = {
      "PASSWORD_STORE_CHARACTER_SET" = "!\\\"#\\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\\\]^_\\`abcdefghijklmnopqrstuvwxyz{|}~";
      "PASSWORD_STORE_DIR" = "${config.home.homeDirectory}/.local/share/password-store";
      "PASSWORD_STORE_GENERATED_LENGTH" = "256";
    };
  };
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".local/share/password-store"
    ];
  };
}
