#!/usr/bin/env bash
set -e

usage() {
    cat <<EOF
Usage: ${0##*/} [-h] [NAME [IMAGE]]

Start the container NAME (creating it from IMAGE if it doesn't exist)
and open a bash shell in it.

  NAME   container name   (default: pi-box)
  IMAGE  image to create from (default: pi-box) 
         only used when the container is first created

  -h     show this help
EOF
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

name=${1:-pi-box}
image=${2:-pi-box}

if ! podman container exists "$name"; then
    podman run -d --init --name "$name" "$image" sleep infinity >/dev/null
elif [ "$(podman inspect -f '{{.State.Running}}' "$name")" != "true" ]; then
    podman start "$name" >/dev/null
fi

exec podman exec -it "$name" bash
