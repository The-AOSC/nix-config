{...}: {
  programs.git = {
    enable = true;
    attributes = [
      "*.gz diff=gzip"
    ];
    ignores = [
      "result"
      "tags"
    ];
    signing = {
      signByDefault = true;
      key = null;
    };
    userName = "The AOSC";
    userEmail = "the-aosc@tutamail.com";
    extraConfig = {
      init = {
        defaultBranch = "master";
      };
      core = {
        autocrlf = "input";
      };
      log.showSignature = true;
      push.autoSetupRemote = true;
      "diff \"gzip\"" = {
        binary = true;
        textconv = "zcat";
      };
    };
  };
}
