{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.gpg.enable = lib.mkEnableOption "gpg";
  };
  config = lib.mkIf config.modules.gpg.enable {
    programs.gpg = {
      enable = true;
      mutableKeys = false;
      mutableTrust = false;
      publicKeys = [
        {
          source = ./The-AOSC.pubkeys;
          trust = "ultimate";
        }
      ];
      scdaemonSettings = {
        disable-ccid = true; # use pcscd instead of fighting with it over device
      };
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-qt;
    };
    home.file = {
      "${config.programs.gpg.homedir}/sshcontrol".source =
        pkgs.runCommand "sshcontrol" {
          buildInputs = [config.programs.gpg.package];
        } ''
          export GNUPGHOME
          GNUPGHOME=$(mktemp -d)
          gpg --with-keygrip --with-colons --show-keys -- ${./The-AOSC.pubkeys} | (
            valid=0
            while read -r line; do
              case "$(cut -d: -f1 <<< "$line")" in
                pub | sub)
                  # authentication key?
                  if cut -d: -f12 <<< $line | grep a -Fq; then
                    valid=1
                  else
                    valid=0
                  fi
                  ;;
                grp)
                  if [[ $valid -eq 1 ]]; then
                    # print keygrip
                    cut -d: -f10 <<< $line
                  fi
                  valid=0
                  ;;
              esac
            done
          ) > $out
        '';
      "${config.programs.gpg.homedir}/private-keys-v1.d".source = ./shadowed-private-keys;
    };
    home.activation = {
      force-private-gpg = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run chmod -077 ${config.home.homeDirectory}/.gnupg
      '';
    };
  };
}
