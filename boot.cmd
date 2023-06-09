# generate boot.scr

fatload mmc 0:1 ${kernel_addr_r} zImage
fatload mmc 0:1 ${fdt_addr_r} bcm2709-rpi-2-b.dtb
# setenv bootargs "earlyprintk root=/dev/mmcblk0p3 rootwait console=tty1 console=ttyAMA0,115200"
# bootz ${kernel_addr_r} - ${fdt_addr_r}
fatload mmc 0:1 ${ramdisk_addr_r} uRamdisk
setenv bootargs "earlyprintk rootwait console=ttyAMA0,115200 rdinit=/sbin/init"
bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
