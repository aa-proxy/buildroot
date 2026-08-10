#!/bin/bash

PROJECT_DIR="$(dirname "$(realpath "$0")")"

BUILDROOT_DIR=${PROJECT_DIR}/buildroot
PATCH_DIR=${PROJECT_DIR}/br-patches
EXTERNAL_DIR=${PROJECT_DIR}/external
CONFIGS_DIR=${EXTERNAL_DIR}/configs

usage() {
    echo "Usage: $0 <board> [options]"
    echo "Options:"
    echo "    -s,--shell   - Init board environment and enter the shell"
    echo "    -r,--rmwork  - Configure RM_WORK option to clean package build directories (saves space)"
    echo "    -v,--verbose - Enable verbose mode"
    echo "    -h,--help    - Show this help message"
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

if [ -z "$1" ]; then
    echo "Error: No board specified."
    usage
    exit 1
fi

BOARD=$1
shift
SHELL_MODE=0
RMWORK_MODE=0
BUILD_VERBOSE=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -s|--shell)
            SHELL_MODE=1
            shift
            ;;
        -r|--rmwork)
            RMWORK_MODE=1
            shift
            ;;

        -v|--verbose)
            BUILD_VERBOSE=1
            shift
            ;;

        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
        ;;
    esac
done

## 
# Check if board config exists
BOARD_CONFIG="${CONFIGS_DIR}/${BOARD}_defconfig"
if [ ! -f "$BOARD_CONFIG" ]; then
    echo "Error: configuration file not found for board '$BOARD'."
    echo "Available boards:"
    find "${CONFIGS_DIR}" -maxdepth 1 -name "*_defconfig" ! -name "gen_*" -exec basename {} _defconfig \;
    exit 1
fi

## 
# Merge configuration files
# make the configs dir writable
sudo chmod a+w ${CONFIGS_DIR}
# merge defconfig for specified board
${EXTERNAL_DIR}/scripts/defconfig_merger.sh ${BOARD}

GEN_CONFIG=${CONFIGS_DIR}/gen_${BOARD}_defconfig
OUTPUT=${BUILDROOT_DIR}/output/${BOARD}
mkdir -p ${OUTPUT}

##
# We need to download the host-tools for MilkV.
# FIXME: consider using the upstream repository (https://github.com/sophgo/host-tools).
# Downloading them into the tBOARDet output and setting BR2_TOOLCHAIN_EXTERNAL_PATH
# doesn't help, because Buildroot still resolves the path as /app/host-tools.
# So the tools must be placed directly in the root /app directory.
if [ "${BOARD}" = "milkv-duos" ]; then
    if [ ! -d /app/host-tools ]; then
        sudo git clone --depth=1 https://github.com/milkv-duo/host-tools.git /app/host-tools
        sudo rm -rf /app/host-tools/.git
    else
        echo "Host tools already present, skipping download."
    fi
fi

##
# Apply buildroot patches
STAMP="$BUILDROOT_DIR/.stamp_patched"
pushd "${BUILDROOT_DIR}" > /dev/null 2>&1 || exit 1
# Exit if already patched
if [ -f "$STAMP" ]; then
    echo "Patch series already applied, skipping."
else
    # Apply Buildroot patches in order
    for p in $(ls "${PATCH_DIR}"/*.patch | sort); do
        echo "Applying patch $(basename "$p")..."
        sudo patch -p1 < "$p"
    done
    # Create stamp file to mark patches applied
    sudo touch "$STAMP"
    echo "All patches applied successfully."
fi
popd > /dev/null 2>&1 || exit 1

## 
# Init buildroot environment
make BR2_EXTERNAL="${EXTERNAL_DIR}" -C "${BUILDROOT_DIR}" O="${OUTPUT}" defconfig BR2_DEFCONFIG="${GEN_CONFIG}" >/dev/null 2>&1 || exit 1
echo "Buildroot environment successfully initialized in: ${OUTPUT}"

##
# Configure RM_WORK (rmwork) in local.mk to persist configuration
if [ "$RMWORK_MODE" -eq 1 ]; then
    echo "Enabling RM_WORK to clean package build directories after compilation"
    [ -f "${OUTPUT}/local.mk" ] && sed -i '/RM_WORK/d' "${OUTPUT}/local.mk"
    echo "RM_WORK=y" >> "${OUTPUT}/local.mk"
else
    [ -f "${OUTPUT}/local.mk" ] && sed -i '/RM_WORK/d' "${OUTPUT}/local.mk"
fi

# cd to output directory
cd "${OUTPUT}" || exit 1

##
# Shell or build image
if [ "$SHELL_MODE" -eq 1 ]; then
    echo "Entering interactive shell..."
    exec /bin/bash
else
    BUILD_LOG="${OUTPUT}/build.log"
    # Launch buildroot build and redirect output build.log
    if [[ ${BUILD_VERBOSE} -eq 1 ]]; then
        # Verbose mode: display full build output and save to log
        # shellcheck disable=SC2086
        make -j "$(nproc --all)" | tee "${BUILD_LOG}" || exit 1
    else
        # Normal mode:
        #   1. Run "make"
        #   2. Save the complete log to build.log
        #   3. Show only high-level ">>> ..." lines on the console
        #   4. On failure, print the last 200 lines of the log for debugging
        # shellcheck disable=SC2086
        make -j "$(nproc --all)" 2>&1 \
        | tee "${BUILD_LOG}" \
        | grep --line-buffered '>>>' \
        || {
            echo "=== Buildroot build failed, last 200 lines of ${BUILD_LOG}: ==="
            tail -200 "${BUILD_LOG}"
            exit 1
        }
    fi
fi
