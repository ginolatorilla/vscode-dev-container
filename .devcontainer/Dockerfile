ARG BASE_IMAGE=ubuntu
FROM $BASE_IMAGE

# These arguments have to be defined here because docker-build will discard every ARG before FROM.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Shut up apt-get warnings!
ENV DEBIAN_FRONTEND=noninteractive

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
# See: https://github.com/docker-library/python/blob/master/Dockerfile-linux.template
ENV LANG=en_US.UTF-8

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
        man-db \
        locales

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
    && yes | unminimize \
    # Set the system locale to suppress future warnings from programs like 'man'.
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

# Get third-party packages
COPY install-packages.sh /tmp/
RUN chmod +x /tmp/install-packages.sh \
    && /tmp/install-packages.sh \
    && rm /tmp/install-packages.sh

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
