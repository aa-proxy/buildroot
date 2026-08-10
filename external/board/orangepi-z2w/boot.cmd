if env exists bootpart; then
	echo Booting from mmcblk${devnum}p${bootpart}
else
	setenv bootpart 2
	echo bootpart not set, default to ${bootpart}
	saveenv
fi

echo "setting boot args"
setenv bootargs "root=/dev/mmcblk${devnum}p${bootpart} console=ttyS2,1500000n8 ro rootwait loglevel=3 init=/etc/overlay_init"

echo "loading device tree ..."
fatload mmc ${devnum}:${bootpart} ${fdt_addr_r} boot/allwinner/sun50i-h618-orangepi-zero2w.dtb

echo "loading kernel image ..."
fatload mmc ${devnum}:${bootpart} ${kernel_addr_r} boot/Image

echo booting linux ...
booti ${kernel_addr_r} - ${fdt_addr_r}
