# pi-box

A persistent Alpine Linux development container with git, Node.js, npm, Emacs and the [Pi coding agent](https://pi.dev), plus a helper script to start it and open a shell.

## Contents

- Alpine 3.24
- `git`, `nodejs`, `npm`, `emacs-nox`, `bash`, `openssh-client`, `less`, `ncurses`
- Pi (`@earendil-works/pi-coding-agent`), installed per user under `~/.local` so it can update itself
- Runs as the non-root user `pi` (home: `/home/pi`)

## Build

```sh
podman build -t pi-box .
```

`start.sh` uses the published image from GitHub Container Registry by default (`ghcr.io/skagget77/pi-box:latest`). To use a local build instead, pass it as `IMAGE`:

```sh
./start.sh -k ~/.ssh/pi-box pi-box pi-box
```

Pi is pinned to a specific version in the `Dockerfile` due to a dependency issue with the `@aws-sdk/credential-provider-node@^3.972.86` package in 1.1.0. Remove the `@<version>` suffix to track the latest release.

## Usage

```sh
./start.sh [-h] [-k KEY] [NAME [IMAGE]]
```

| Argument | Default   | Description                                                        |
|----------|-----------|--------------------------------------------------------------------|
| `NAME`   | `pi-box`  | Container name                                                     |
| `IMAGE`  | `ghcr.io/skagget77/pi-box:latest` | Image to create from                         |
| `-k KEY` |           | Private key file to copy into the container (see [SSH key](#ssh-key)) |
| `-h`     |           | Show help                                                          |

The script:

1. Creates the container if it doesn't exist (`podman run -d --init ... sleep infinity`).
2. If `-k` is given, copies the key to `~/.ssh/` in the container and writes an ssh config that uses it for all hosts.
3. Starts the container if it is stopped.
4. Opens a bash shell in it with `podman exec -it`.

Run it from as many terminals as you like; each gets its own shell in the same container.

Options must come before `NAME` and `IMAGE`. `NAME`, `IMAGE` and `-k` only take effect when the container is first created.

## SSH key

Generate a dedicated key, add the public half to GitHub (Settings → SSH and GPG keys), and pass the private key when creating the container:

```sh
ssh-keygen -t ed25519 -f ~/.ssh/pi-box -C pi-box
./start.sh -k ~/.ssh/pi-box
```

Using a separate key means you can revoke it without touching your other keys.

## Publishing

A GitHub Actions workflow (`.github/workflows/publish.yml`) builds the image and pushes it to `ghcr.io/skagget77/pi-box`. A push to `main` publishes `latest`, and a tag like `v1.0.0` also publishes `1.0.0`. The package is private until you make it public in its GitHub package settings.

## Notes

- Nothing is mounted. Pi's config, API keys and sessions live in the container's filesystem under `/home/pi/.pi/agent/` and persist across stop/start, but are lost when the container is removed. The same goes for the ssh key.
- Docker works too: replace `podman` with `docker`. The script uses `podman container exists`, which has no direct Docker equivalent, so adjust that check if you switch.
