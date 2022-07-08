# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.238.0/containers/ubuntu/.devcontainer/base.Dockerfile
FROM ubuntu:latest

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL >> /etc/sudoers

# My tools
RUN apt-get install -y --no-install-recommends git python3 fish

# Install Docker CE CLI
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg2 lsb-release \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - 2>/dev/null \
    && echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin

# This removes your password so you can run `sudo` quickly. Bad! You know what you're doing.
RUN chsh -s /usr/bin/fish $USERNAME \
    && passwd -d $USERNAME

# This allows you to run docker commands without sudo
# Default to root only access to the Docker socket, set up non-root init script
RUN touch /var/run/docker-host.sock \
    && ln -s /var/run/docker-host.sock /var/run/docker.sock \
    && apt-get update \
    && apt-get -y install socat

# Create docker-init.sh to spin up socat
RUN echo "#!/bin/sh\n\
    sudoIf() { if [ \"\$(id -u)\" -ne 0 ]; then sudo \"\$@\"; else \"\$@\"; fi }\n\
    sudoIf rm -rf /var/run/docker.sock\n\
    ((sudoIf socat UNIX-LISTEN:/var/run/docker.sock,fork,mode=660,user=${USERNAME} UNIX-CONNECT:/var/run/docker-host.sock) 2>&1 >> /tmp/vscr-docker-from-docker.log) & > /dev/null\n\
    \"\$@\"" >> /usr/local/share/docker-init.sh \
    && chmod +x /usr/local/share/docker-init.sh

# More apps
RUN apt-get install -y --no-install-recommends man-db && yes | unminimize
RUN apt-get install -y --no-install-recommends ssh rsync

# See https://www.getpagespeed.com/work/proper-use-of-ssh-client-in-mac-os-x
ENV SSH_AGENT_SOCK=/var/run/ssh-agent.sock

# VS Code overrides ENTRYPOINT and CMD when executing `docker run` by default.
# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to
# the Docker socket if "overrideCommand": false is set in devcontainer.json.
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
