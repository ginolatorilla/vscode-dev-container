# My VSCode Development Container

Here I define my development container that I use with the [Remote - Containers](https://aka.ms/vscode-remote/)
plugin in VSCode. This is oriented for a DevOps role.

## Usage

1. Copy the `.devcontainer` folder in the host directory you want to open inside a development container.
2. Open the command palette and run the "Remote-Containers: Open Folder in Container..." command
3. Wait for the image to be rebuilt and viola!

## Features

- Your host's username will be used inside. You can run `sudo` to elevate permissions.
- Run `docker` inside. The container's Docker CLI will connect to the host's Docker daemon.
- Preserve your shell history and configuration files across containers. Your host's home directory will be mounted.
- Hook script if you need custom initialisation of the container.
- Third-party packages are listed in `.devcontainer/install-packages.sh` so that you can use this script in a Linux host (e.g. WSL2).
