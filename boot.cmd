# generate boot.scr

# network stuff
setenv serverip 192.168.3.1
setenv ipaddr 192.168.3.2
setenv netmask 255.255.255.0

# bootargs
setenv bootargs "earlyprintk rootwait console=ttyAMA0,115200 rdinit=/sbin/init"

# u-boot env
setenv tftpbootcmd "tftp ${kernel_addr_r} ${serverip}:zImage; tftp ${fdt_addr_r} ${serverip}:bcm2709-rpi-2-b.dtb; tftp ${ramdisk_addr_r} ${serverip}:uRamdisk; bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}"
#

# linux normal
setenv linuxbootcmd "fatload mmc 0:1 ${kernel_addr_r} zImage; fatload mmc 0:1 ${fdt_addr_r} bcm2709-rpi-2-b.dtb; fatload mmc 0:1 ${ramdisk_addr_r} uRamdisk; bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}"
#

saveenv


# for android
setenv bootargs "earlyprintk rootwait console=ttyAMA0,115200 rdinit=/init"
fatload mmc 0:1 ${kernel_addr_r} boot.img
# fatload mmc 0:1 ${ramdisk_addr_r} uRamdisk
fatload mmc 0:1 ${fdt_addr_r} bcm2709-rpi-2-b.dtb
bootm ${kernel_addr_r} ${kernel_addr_r} ${fdt_addr_r}
