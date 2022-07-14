ARG BASE_IMAGE=ubuntu
FROM $BASE_IMAGE

# These arguments have to be defined here because docker-build will discard every ARG before FROM.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG OPENSHIFT_CONSOLE_DOMAIN=''

# Shut up apt-get warnings!
ENV DEBIAN_FRONTEND=noninteractive

# Forward the host's ssh-agent. See mounts in devcontainer.json.
ENV SSH_AGENT_SOCK=/var/run/ssh-agent.sock

COPY init.sh /usr/local/share/

# Install essentials
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        fish \
        ca-certificates \
        curl \
        gnupg2 \
        lsb-release \
        socat \
        man-db

# Add yourself as a non-root user that can still run as root.
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL >> /etc/sudoers \
    # This removes your password so you can run `sudo` quickly. Bad! You know what you're doing.
    && passwd -d ${USERNAME} \
    && chsh -s /usr/bin/fish $USERNAME \
    # This allows you to run docker commands without sudo.
    && touch /var/run/docker-host.sock \
    && ln -s /var/run/docker-host.sock /var/run/docker.sock \
    && echo "#!/bin/sh\n\
    sudoIf() { if [ \"\$(id -u)\" -ne 0 ]; then sudo \"\$@\"; else \"\$@\"; fi }\n\
    sudoIf rm -rf /var/run/docker.sock\n\
    ((sudoIf socat UNIX-LISTEN:/var/run/docker.sock,fork,mode=660,user=${USERNAME} UNIX-CONNECT:/var/run/docker-host.sock) 2>&1 >> /tmp/vscr-docker-from-docker.log) & > /dev/null\n\
    /usr/local/share/init.sh\n\
    \"\$@\"" >> /usr/local/share/docker-init.sh \
    && chmod +x /usr/local/share/docker-init.sh \
    && chmod +x /usr/local/share/init.sh \
    # Expand all manual pages.
    && yes | unminimize

# Get third-party packages
RUN curl -fsSL "https://download.docker.com/linux/$(lsb_release -i | tr '[:upper:]' '[:lower:]' | cut -d ':' -f 2 | tr -d '[:space:]')/gpg" | apt-key add - 2>/dev/null \
    && echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$(lsb_release -i | tr '[:upper:]' '[:lower:]' | cut -d ':' -f 2 | tr -d '[:space:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker-ce-cli \
        docker-compose-plugin \
        kubectl \
        git \
        python3 \
        python3-pip \
        man-db \
        ssh \
        rsync \
        less \
        htop \
        iproute2 \
    && apt-get autoremove -y \
    && apt-get autoclean -y

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# Install optional third-party packages
RUN if [ -n "${OPENSHIFT_CONSOLE_DOMAIN}" ]; then \
    mkdir -p /opt/openshift/bin \
    && cd /opt/openshift/bin \
    && curl -o oc.tar -fSSL https://$(echo $OPENSHIFT_CONSOLE_DOMAIN | sed 's/^console/downloads/g')/$(dpkg --print-architecture)/linux/oc.tar \
    && tar xvf oc.tar \
    && chmod +x oc \
    ; fi

ENV PATH "$PATH:/opt/openshift/bin"
