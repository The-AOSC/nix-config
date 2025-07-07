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
    };
    home.activation = {
      force-private-gpg = lib.hm.dag.entryAfter ["writeBoundary" "createAndMountPersistentStoragePaths"] ''
        run chmod -077 ${config.home.homeDirectory}/.gnupg
        run chmod -077 /persist/home/aosc/.gnupg
        run chmod -077 /persist/home/aosc/.gnupg/private-keys-v1.d
      '';
    };
    home.persistence."/persist/home/aosc" = {
      directories = [
        ".gnupg/private-keys-v1.d"
      ];
    };
  };
}
