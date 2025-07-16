#!/bin/bash

if [[ $1 == "build" ]]; then
    docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t aaproxybr .
else
    docker run -it --rm \
      -v "$(pwd):/app" \
      aaproxybr \
      /bin/bash
fi
