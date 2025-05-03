{
  amd = import ./amd;
  base = import ./base.nix;
  desktop = import ./desktop.nix;
  gitlab = import ./gitlab;
  kanata = import ./kanata;
  kdeconnect = import ./kdeconnect;
  netConfig = import ./netConfig;
  ntp = import ./ntp;
  persistence = import ./persistence;
  sshd = import ./sshd;
  swaylock = import ./swaylock;
  tor = import ./tor;
  virt-manager = import ./virt-manager;
  wine = import ./wine;
  zapret = import ./zapret;
}
