{lib, ...}: {
  home.activation = {
    force-private-ssh = lib.hm.dag.entryAfter ["writeBoundary" "createAndMountPersistentStoragePaths"] ''
      run chmod -077 /persist/home/aosc/.ssh
    '';
  };
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".ssh"
    ];
  };
}
