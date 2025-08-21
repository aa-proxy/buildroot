#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Print error and exit if no argument is provided
if [ -z "$1" ]; then
    echo "Error: No argument provided."
    echo "Usage: $0 <board>"
    exit 1
fi

ARG=$1
CONFIG_DIR="external/configs"
GEN_DEFCONFIG="${CONFIG_DIR}/gen_${ARG}_defconfig"

# Prepare the list of configuration files to concatenate:
# Start with the common config used by all boards
FILES=("${CONFIG_DIR}/common.part")

# If the board name starts with "rpi", include the Raspberry Pi-specific config
[[ "$ARG" == rpi* ]] && FILES+=("${CONFIG_DIR}/common_rpi.part")

# Finally, add the board-specific defconfig
FILES+=("${CONFIG_DIR}/${ARG}_defconfig")

# Check if all required files exist
for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file '$file' not found."
        exit 1
    fi
done

# Merge all config files:
# - remove duplicate keys (keeping the last occurrence)
# - sort the final output alphabetically
cat "${FILES[@]}" | awk -F'=' '/^[^#]/{a[$1]=$0} END {for (i in a) print a[i]}' | sort > "${GEN_DEFCONFIG}"

echo "Generated config: ${GEN_DEFCONFIG}"
