setenv load_addr "0x6000000"

saveenv
if env exists bootpart; then
	echo Booting from mmcblk${devnum}p${bootpart}
else
	setenv bootpart 2
	echo bootpart not set, default to ${bootpart}
fi

echo "setting boot args"
setenv bootargs "root=/dev/mmcblk${devnum}p${bootpart} console=ttyS2,1500000n8 ro rootwait loglevel=3 init=/etc/overlay_init"
fatload mmc ${devnum}:1 ${fdt_addr_r} rk3566-radxa-zero-3w.dtb
fatload mmc ${devnum}:1 ${kernel_addr_r} Image.gz

echo booting linux ...
booti ${kernel_addr_r} - ${fdt_addr_r}
