FROM debian:bookworm-slim

ARG USERNAME=buildroot
ARG UID=1000
ARG GID=1000

ENV LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    file \
    wget \
    cpio \
    rsync \
    python3 \
    python3-setuptools \
    git \
    unzip \
    bc \
    vim \
    libssl-dev \
    libncurses-dev \
    build-essential \
    bash \
    perl \
    ca-certificates \
    python-is-python3 \
    libfl-dev \
    wireless-regdb \
    device-tree-compiler \
    sudo && \
# Create user and group to not use root
    groupadd --gid ${GID} ${USERNAME} && \
    useradd --uid ${UID} --gid ${GID} -m ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    apt-get autoremove -y

USER ${USERNAME}

WORKDIR /app

ENV SHELL=/bin/bash

COPY build-image.sh /build-image.sh
ENTRYPOINT ["/build-image.sh"]
