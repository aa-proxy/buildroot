#!/bin/sh

BUILDROOT_DIR="$(realpath "$BR2_EXTERNAL_AA_PROXY_OS_PATH/..")"
git config --global --add safe.directory "$BUILDROOT_DIR"
BUILDROOT_COMMIT=$(git -C "$BUILDROOT_DIR" log -n1 --pretty=format:%h HEAD)

cat <<EOF > "$TARGET_DIR/etc/issue"
Welcome to aa-proxy

 .---.-.---.-.______.-----.----.-----.--.--.--.--.
 |  _  |  _  |______|  _  |   _|  _  |_   _|  |  |
 |___._|___._|      |   __|__| |_____|__.__|___  |
                    |__|                   |_____|

https://github.com/aa-proxy/aa-proxy-rs
build date: $(date +%Y-%m-%d), br# $BUILDROOT_COMMIT

EOF
