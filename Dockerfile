FROM alpine:3.22

ARG USERNAME=buildroot
ARG UID=1000
ARG GID=1000

ENV LANG=C.UTF-8

RUN apk update && apk add --no-cache \
    file \
    wget \
    cpio \
    rsync \
    python3 \
    py3-setuptools \
    git \
    unzip \
    bc \
    vim \
    openssl-dev \
    ncurses-dev \
    build-base \
    libc6-compat \
    bash \
    shadow

# Create user and group to not use root
RUN apk add --no-cache sudo \
  && addgroup -g ${GID} ${USERNAME} \
  && adduser -D -u ${UID} -G ${USERNAME} ${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}

WORKDIR /app

ENV SHELL=/bin/bash
