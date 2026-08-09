#!/bin/bash
set -euo pipefail

# 
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat <<EOF
Usage: $0 [build|shell|<board>] [board_options...]

Commands:
  build              Build the aaproxybr container image
  <board>            Run build-image.sh for the given board inside the container
  (no argument)      Enter a bare shell in the container, without any board setup

[board_options...] are forwarded as-is to build-image.sh

Environment:
  CONTAINER_ENGINE   Force the container engine to use (podman or docker)
EOF
    exit 0
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Determine container engine
if [[ -n "${CONTAINER_ENGINE:-}" ]]; then
    # Use value from env if set
    ENGINE="$CONTAINER_ENGINE"
    if ! command_exists "$ENGINE"; then
        echo "ERROR: Specified CONTAINER_ENGINE '$ENGINE' is not installed." >&2
        exit 1
    fi
else
    # Auto-detect: prefer podman
    if command_exists "podman"; then
        ENGINE="podman"
    elif command_exists "docker"; then
        ENGINE="docker"
    else
        echo "ERROR: Neither podman nor docker is available." >&2
        exit 1
    fi
fi

# Set user namespace argument only for podman
USERNS_ARG=""
if [[ "$ENGINE" == "podman" ]]; then
    USERNS_ARG="--userns=keep-id"
fi

# Get command
CMD="${1:-}"

if [[ "$CMD" == "build" ]]; then
    echo "Building image with $ENGINE..."
    "$ENGINE" build \
        --build-arg UID="$(id -u)" \
        --build-arg GID="$(id -g)" \
        -t aaproxybr .
    exit $?
elif [[ -z "$CMD" ]]; then
    # No argument: drop straight into a bare shell
    ENTRY="/bin/bash"
    # clear all the arguments
    set --
else
    # Any other argument is forwarded as the board to build-image.sh
    ENTRY="/app/build-image.sh"
fi

# Use -it only if TTY is available (e.g., not in CI)
if [ -t 1 ]; then
  INTERACTIVE="-it"
else
  INTERACTIVE=""
fi

echo "Running container with $ENGINE: aaproxybr $ENTRY $*"
"$ENGINE" run $USERNS_ARG $INTERACTIVE --rm \
    -v "$(pwd):/app":z \
    aaproxybr \
    "$ENTRY" "$@"
exit $?