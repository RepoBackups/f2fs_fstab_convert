#!/sbin/sh
#Features: 
#extracts ramdisk
#checks mounts for f2fs/ext4
#modifies fstab
#repacks the ramdisk

# get file descriptor for output (CWM)

OUTFD=$(ps | grep -v "grep" | grep -o -E "update_binary(.*)" | cut -d " " -f 3);

# get file descriptor for output (TWRP)
[ $OUTFD != "" ] || OUTFD=$(ps | grep -v "grep" | grep -o -E "updater(.*)" | cut -d " " -f 3)

# functions to send output to recovery
progress() {
  if [ $OUTFD != "" ]; then
    echo "progress ${1} ${2} " 1>&$OUTFD;
  fi;
}

set_progress() {
  if [ $OUTFD != "" ]; then
    echo "set_progress ${1} " 1>&$OUTFD;
  fi;
}

ui_print() {
  if [ $OUTFD != "" ]; then
    echo "ui_print ${1} " 1>&$OUTFD;
    echo "ui_print " 1>&$OUTFD;
  else
    echo "${1}";
  fi;
}

mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i
cd /

#find hboot version
val=$(cat /tmp/aroma-data/aroma.prop | cut -d"=" -f2)
case $val in
  1)
    hboot="215"
    ;;
  2)
    hboot="216"
    ;;
esac

# make sure all the needed partitions are mounted so they show up in mount
# this may output errors if the partition is already mounted (/data and /cache probably will be), so pipe them to /dev/null
# make sure we mount /system before calling any additional shell scripts,
# because they may use /system/bin/sh instead of /sbin/sh and that may cause problems
mount /system 2> /dev/null
mount /cache 2> /dev/null
mount /data 2> /dev/null

# find out which partitions are formatted as F2FS
mount | grep -q 'data type f2fs'
DATA_F2FS=$?
ui_print "Data f2f result=$DATA_F2FS "
mount | grep -q 'cache type f2fs'
CACHE_F2FS=$?
ui_print "Cache f2f result=$CACHE_F2FS "
mount | grep -q 'system type f2fs'
SYSTEM_F2FS=$?
ui_print "System f2f result=$SYSTEM_F2FS "

if [ $SYSTEM_F2FS -eq 0 ]; then
	$BB sed -i "s/# F2FSSYS//g" /tmp/fstab$hboot.qcom.tmp;
else
	$BB sed -i "s/# EXT4SYS//g" /tmp/fstab$hboot.qcom.tmp;
fi;

if [ $CACHE_F2FS -eq 0 ]; then
	$BB sed -i "s/# F2FSCAC//g" /tmp/fstab$hboot.qcom.tmp;
else
	$BB sed -i "s/# EXT4CAC//g" /tmp/fstab$hboot.qcom.tmp;
fi;

if [ $DATA_F2FS -eq 0 ]; then
	$BB sed -i "s/# F2FSDAT//g" /tmp/fstab$hboot.qcom.tmp;
else
	$BB sed -i "s/# EXT4DAT//g" /tmp/fstab$hboot.qcom.tmp;
fi;

cp /tmp/fstab.qcom.tmp /tmp/fstab.qcom.tmp1;
rm /tmp/ramdisk/fstab.qcom
mv /tmp/fstab$hboot.qcom.tmp /tmp/ramdisk/fstab.qcom;

rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/boot.img-ramdisk.gz
cd /tmp/ramdisk/
find . | cpio -o -H newc | gzip > ../boot.img-ramdisk.gz
cd /
