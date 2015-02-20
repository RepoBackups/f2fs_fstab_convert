f2fs_fstab_convert_script

This is a simple anyKernel style script package that detects fs types for /system, /data, and /cache and modifies the fstab accordingly.

The installer script does the following:

Extracts needed tools/files
Mounts /system, /data, /cache
Copies over f2fs tools (mkfs.f2fs, fsck.f2fs, and fibmap.f2fs)
Extract ramdisk
Check mounts and edit fstab according to results
Repack ramdisk and boot.img
Flash new boot.img
This was specifically designed for HTC VILLE but can be modified for other devices as well.

A compatable f2fs enabled kernel can also be added by replacign the zImage and modifying kernel/mkbootimg.sh to use this new zImage instead of the devices existing zImage when repacking the boot.img

To zip package: zip -r .zip *

Work on this package was derived from multiple sources including: Koush (original anykernel zip) osm0sis@xda-developers (scripting) Peteragent5, alansj & iridaki@xda-developers (general method) frantisek.nesveda ktoonsez alucard24 dorimanx Metallice jrior001 - Modified to fit in with Ville anykernel zip
