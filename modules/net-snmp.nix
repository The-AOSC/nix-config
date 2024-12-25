{config, ...}: {
  modules.options.net-snmp = {};
  networking.firewall.allowedUDPPorts = config.modules.lib.withModuleUsersConfig "net-snmp" [
    162  # SNMPTRAP
  ];
}
