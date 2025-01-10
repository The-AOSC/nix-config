{...}: {
  imports = [
    ./modules
  ];
  modules.modules = {
    unfree-fonts.enable = true;
  };
  environment.persistence."/persist/storage" = {
    users.vladimir = {
      directories = [
        "inst"
      ];
    };
  };
}
