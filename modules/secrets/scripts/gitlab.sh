#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages bash coreutils gnused openssl

if [ $# -eq 0 ]; then
    printf 'Usage: %s [OUTPUT_FILE]\n' "$0" >&2
    printf 'Generate new secrets for gitlab.\n' >&2
    printf "Use 'EDITOR=\"./scripts/gitlab.sh\" sops gitlab-secrets.yaml' to generate encrypted secrets.\n" >&2
    exit 1
elif [ "a$1" = "a-" ]; then
    :
else
    exec > "$1"
fi

printf '# random 128 ASCII printable bytes\n'
printf 'database-password: |-\n'
printf '  '
tr -dc "[:graph:]" < /dev/random | head -c 128
printf '\n'

printf '# random 128 ASCII printable bytes\n'
printf 'initial-root-password: |-\n'
printf '  '
tr -dc "[:graph:]" < /dev/random | head -c 128
printf '\n'

printf '# random 128 ASCII printable bytes\n'
printf 'secret: |-\n'
printf '  '
tr -dc "[:graph:]" < /dev/random | head -c 128
printf '\n'

printf '# random 128 ASCII printable bytes\n'
printf 'db: |-\n'
printf '  '
tr -dc "[:graph:]" < /dev/random | head -c 128
printf '\n'

printf '# random 128 ASCII printable bytes\n'
printf 'otp: |-\n'
printf '  '
tr -dc "[:graph:]" < /dev/random | head -c 128
printf '\n'

printf "# ssh key generated with 'openssl genrsa 4096'\n"
printf 'jws: |\n'
openssl genrsa 4096 | sed 's/^/  /'

printf '# random 32 ASCII printable bytes\n'
printf 'active-record-deterministic-key: |-\n'
printf '  '
tr -dc "[:graph:]" < /dev/random | head -c 32
printf '\n'

printf '# random 32 ASCII printable bytes\n'
printf 'active-record-primary-key: |-\n'
printf '  '
tr -dc "[:graph:]" < /dev/random | head -c 32
printf '\n'

printf '# random 32 ASCII printable bytes\n'
printf 'active-record-salt: |-\n'
printf '  '
tr -dc "[:graph:]" < /dev/random | head -c 32
printf '\n'
