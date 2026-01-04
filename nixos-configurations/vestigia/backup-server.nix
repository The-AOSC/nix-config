{config, ...}: {
  services.borgbackup.repos.backup = {
    authorizedKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJYe+7Tc/RFBYgueO3doR88DR883nvuQhvbUXqoVtLLvPU42dgkR76l29fPxUdH/oq1vF23uVPjkXqu9bJE5Ch+N5HMwVd5fDpXJA8/xl/baCibHze7hiGGZFd/Oa9JpGGySZVztJ/nY3GbguERHjZHvm/vr+FMEP86H6ApJWsrqRnnmhtt6BLDaYlXVtJtu+NtcB2DQHTkBfThEG/tQjpLJH8XyAFo1uLMg3vWm78blfmhKT+4SjhJVmiqjW75Ghz+T2RkGYn6gG9rRMphsVKmubxXXFcvGJS3821qK7fO6lmOgClW39oXIQbImSuX7KPyMaVdk4sNxbadUE47QRetl28tPwvVA2BLC7QHHMdkgzQbruiiOfizYOYVM6t8z6jxTy8xuTbJsgr7I21PVmV31mdXTVZOp8jH8JRjv9s7sNl85AFEQCFAua5YfIpmj+P2MPH4zdN6Z71qTlvR+7/AzoejCWjILwRBOY5p69OFixwvvOaCFnzeLVcCkeO5wmOM1bEQJhXdMYMczhSiCbVQa1sMkK10SZLDm72oolDpc6qihmPfMOxankQeVAmHZwZlt11XrlqWIPbsdqjxvL5NdmrkVrH0KI1YT2JsEc06BLneTsmTS4Se+COX33U1C5dm8mBQ9/uRMp2WR4UsxynDLOjN5JQgctW2GFlykCp1w== root@evacuis"
    ];
    path = "/backup/backup";
  };
  services.openssh.settings.AllowGroups = [config.services.borgbackup.repos.backup.group];
}
