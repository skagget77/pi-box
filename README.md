# pi-box

A persistent Alpine Linux development container with git, Node.js, npm, Emacs and the [Pi coding agent](https://pi.dev), plus a helper script to start it and open a shell.

## Contents

- Alpine 3.24
- `git`, `nodejs`, `npm`, `emacs-nox`, `bash`
- Pi (`@earendil-works/pi-coding-agent`), installed per user under `~/.local` so it can update itself
- Runs as the non-root user `pi` (home: `/home/pi`)

## Build

```sh
podman build -t pi-box .
```

Pi is pinned to a specific version in the `Dockerfile` due a dependency issue with the `@aws-sdk/credential-provider-node@^3.972.86` package in 1.1.0. Remove the `@<version>` suffix to track the latest release.

## Usage

```sh
./start.sh [-h] [NAME [IMAGE]]
```

| Argument | Default      | Description                                   |
|----------|--------------|-----------------------------------------------|
| `NAME`   | `pi-box      | Container name                                |
| `IMAGE`  | `pi-box`     | Image to create from (only used on creation)  |
| `-h`     |              | Show help                                     |

The script:

1. Creates the container if it doesn't exist (`podman run -d --init ... sleep infinity`).
2. Starts it if it is stopped.
3. Opens a bash shell in it with `podman exec -it`.

Run it from as many terminals as you like; each gets its own shell in the same container.

## Notes

- Nothing is mounted. Pi's config, API keys and sessions live in the container's filesystem under `/home/pi/.pi/agent/` and persist across stop/start, but are lost when the container is removed.
- Docker works too: replace `podman` with `docker`. The script uses `podman container exists`, which has no direct Docker equivalent, so adjust that check if you switch.