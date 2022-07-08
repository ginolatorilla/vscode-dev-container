ARG BASE_IMAGE=ubuntu
FROM $BASE_IMAGE

# These arguments have to be defined here because docker-build will discard every ARG before FROM.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Shut up apt-get warnings!
ENV DEBIAN_FRONTEND=noninteractive

# Forward the host's ssh-agent. See mounts in devcontainer.json.
ENV SSH_AGENT_SOCK=/var/run/ssh-agent.sock

# Add yourself as a non-root user that can still run as root.
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL >> /etc/sudoers

# This removes your password so you can run `sudo` quickly. Bad! You know what you're doing.
RUN chsh -s /usr/bin/fish $USERNAME \
    && passwd -d $USERNAME

# Install Docker CE CLI and Docker compose
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg2 lsb-release \
    && curl -fsSL "https://download.docker.com/linux/$(lsb_release -i | tr '[:upper:]' '[:lower:]' | cut -d ':' -f 2 | tr -d '[:space:]')/gpg" | apt-key add - 2>/dev/null \
    && echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$(lsb_release -i | tr '[:upper:]' '[:lower:]' | cut -d ':' -f 2 | tr -d '[:space:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin

# This allows you to run docker commands without sudo.
COPY init.sh /usr/local/share/
RUN touch /var/run/docker-host.sock \
    && ln -s /var/run/docker-host.sock /var/run/docker.sock \
    && apt-get update \
    && apt-get -y install socat \
    && echo "#!/bin/sh\n\
    sudoIf() { if [ \"\$(id -u)\" -ne 0 ]; then sudo \"\$@\"; else \"\$@\"; fi }\n\
    sudoIf rm -rf /var/run/docker.sock\n\
    ((sudoIf socat UNIX-LISTEN:/var/run/docker.sock,fork,mode=660,user=${USERNAME} UNIX-CONNECT:/var/run/docker-host.sock) 2>&1 >> /tmp/vscr-docker-from-docker.log) & > /dev/null\n\
    /usr/local/share/init.sh\n\
    \"\$@\"" >> /usr/local/share/docker-init.sh \
    && chmod +x /usr/local/share/docker-init.sh \
    && chmod +x /usr/local/share/init.sh
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# Expand all manual pages.
RUN apt-get update \
    && apt-get install -y --no-install-recommends man-db \
    && yes | unminimize

# Here I list the things I want to install without any special preparations.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        python3 \
        fish \
        man-db \
        ssh \
        rsync \
    && apt-get autoremove -y \
    && apt-get autoclean -y
