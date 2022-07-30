#!/bin/bash
set -o pipefail
set -e

__distro__=$(lsb_release -i | tr '[:upper:]' '[:lower:]' | cut -d ':' -f 2 | tr -d '[:space:]')
__arch__=$(dpkg --print-architecture)

curl -fsSL "https://download.docker.com/linux/${__distro__}/gpg" | apt-key add - 2>/dev/null
echo "deb [arch=${__arch__}] https://download.docker.com/linux/${__distro__} $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y --no-install-recommends \
    docker-ce-cli \
    docker-compose-plugin \
    git \
    python3 \
    python3-pip \
    man-db \
    ssh \
    rsync \
    less \
    htop \
    iproute2 \
    parallel \
    file \
    jq \
    tree
apt-get autoremove -y
apt-get autoclean -y
