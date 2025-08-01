#!/bin/bash

# Function to check for a command
command_exists () {
    command -v "$1" >/dev/null 2>&1
}

if command_exists "podman"; then
    PODMAN_ARG=--userns=keep-id
else
    PODMAN_ARG=
fi

if [[ $1 == "build" ]]; then
    docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t aaproxybr .
else
    docker run ${PODMAN_ARG} -it --rm \
      -v "$(pwd):/app":z \
      aaproxybr \
      $1
fi
