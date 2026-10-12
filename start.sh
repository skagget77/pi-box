#!/usr/bin/env bash
set -e

usage() {
    cat <<EOF
Usage: ${0##*/} [-h] [-k KEY] [NAME [IMAGE]]

Start the container NAME (creating it from IMAGE if it doesn't exist)
and open a bash shell in it.

  NAME   container name   (default: pi-box)
  IMAGE  image to create from (default: pi-box)

  -k KEY copy the private key file KEY to ~/.ssh/ in the container and
         write an ssh config that uses it for all hosts
  -h     show this help

NAME, IMAGE and -k only take effect when the container is first created.
EOF
}

[ "$1" = "--help" ] && { usage; exit 0; }

key=
while getopts "hk:" opt; do
    case $opt in
        h) usage; exit 0 ;;
        k) key=$OPTARG ;;
        *) usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

name=${1:-pi-box}
image=${2:-pi-box}

if [ -n "$key" ] && [ ! -f "$key" ]; then
    echo "error: key file not found: $key" >&2
    exit 1
fi

if ! podman container exists "$name"; then
    podman run -d --init --name "$name" "$image" sleep infinity >/dev/null
    if [ -n "$key" ]; then
        keyname=${key##*/}
        podman exec "$name" mkdir -p -m 700 /home/pi/.ssh
        podman cp "$key" "$name:/home/pi/.ssh/$keyname"
        podman exec "$name" sh -c \
            'printf "Host *\n  IdentityFile ~/.ssh/%s\n  IdentitiesOnly yes\n" "$1" > ~/.ssh/config' \
            sh "$keyname"
    fi
elif [ "$(podman inspect -f '{{.State.Running}}' "$name")" != "true" ]; then
    podman start "$name" >/dev/null
fi

exec podman exec -it "$name" bash
