# My VSCode Development Container

Here I define my development container that I use with the [Remote - Containers](https://aka.ms/vscode-remote/)
plugin in VSCode. This is oriented for a DevOps role.

## Features

- Your host's username will be used inside. You can run `sudo` to elevate permissions.
- Run `docker` inside. The container's Docker CLI will connect to the host's Docker daemon.
- Preserve your home directory (shell history and configuration files) across container rebuilds.
- Hook script if you need custom initialisation of the container.
- Third-party packages are listed in `.devcontainer/install-packages.sh` so that you can use this script in a Linux host (e.g. WSL2).
- Integrates with [ginolatorilla/dotfiles](https://github.com/ginolatorilla/dotfiles).

## Installation

### Windows

1. Install [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install).
2. Install [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/).
3. Go to **Docker Desktop Settings** and check **Use the WSL 2 based engine**.
4. Install [VSCode](https://code.visualstudio.com/), and the extensions
   [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) and
   [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl).
5. Connect VSCode to WSL2 using the **Remote - WSL** extension.
6. Open a terminal, clone this repo, and reopen it in VSCode.
7. Open the **Command Palette** _(Ctrl+Shift+P)_ and select **Rebuild Container**.

### Mac

1. Install [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/).
2. Install [VSCode](https://code.visualstudio.com/), and the extension
   [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
3. Clone this repo and reopen it in VSCode.
4. Open the **Command Palette** _(Ctrl+Shift+P)_ and select **Rebuild Container**.

### Linux

1. Install [Docker Desktop](https://docs.docker.com/desktop/install/linux-install/) or [Docker Engine](https://docs.docker.com/engine/install/).
2. Install [VSCode](https://code.visualstudio.com/), and the extension
   [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
3. Clone this repo and reopen it in VSCode.
4. Open the **Command Palette** _(Ctrl+Shift+P)_ and select **Rebuild Container**.

## Usage Patterns

### Access the host's SSH agent

Use this Bash script to reconnect to the SSH agent socket that's created by VSCode:

```bash
export SSH_AUTH_SOCK=$(find /tmp -name 'vscode-ssh-auth-*')
```

You may also use this script to attach to the container from outside VSCode:

```bash
DEVCONTAINER=$(docker container ls | grep vscode-dev-container | awk '{print $1}')
SSH_AUTH_IN_CONTAINER=$(docker exec $DEVCONTAINER sh -c 'ls -t /tmp/vscode-ssh-auth* 2>/dev/null' | head -1)
docker exec -it -e SSH_AUTH_SOCK=$SSH_AUTH_IN_CONTAINER -u $USER -w /home/$USER $DEVCONTAINER bash
```
