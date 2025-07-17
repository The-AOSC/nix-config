#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages bash coreutils mkpasswd

if [ $# -eq 0 ]; then
    printf 'Usage: %s [OUTPUT_FILE]\n' "$0" >&2
    printf 'Generate hashed password for user\n' >&2
    printf "Use 'EDITOR=\"./scripts/password.sh\" sops <user>-password.yaml' to generate encrypted secrets.\n" >&2
    exit 1
elif [ "a$1" = "a-" ]; then
    :
else
    exec > "$1"
fi

printf 'hash: '
mkpasswd
