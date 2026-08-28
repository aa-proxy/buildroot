if env exists bootpart; then
	echo "Booting from mmcblk${devnum}p${bootpart}"
else
	setenv bootpart 2
	echo "bootpart not set, default to ${bootpart}"
	saveenv
fi

echo "Setting boot args"
setenv bootargs "root=/dev/mmcblk${devnum}p${bootpart} console=${console} ro rootwait loglevel=3 init=/etc/overlay_init"

echo "Loading device tree ..."
ext4load mmc ${devnum}:${bootpart} ${fdt_addr_r} boot/sun50i-h618-orangepi-zero2w.dtb

echo "Loading kernel image ..."
ext4load mmc ${devnum}:${bootpart} ${kernel_addr_r} boot/Image

echo "Booting linux ..."
booti ${kernel_addr_r} - ${fdt_addr_r}
