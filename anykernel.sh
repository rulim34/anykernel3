# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# Begin properties
properties() { '
kernel.string=
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=1
device.name1=riva
supported.versions=10
supported.patchlevels=
'; } # End properties

# Shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## End setup

## AnyKernel methods (DO NOT CHANGE)
# Import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# Set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;

## AnyKernel install

# Treble Check
is_treble=$(file_getprop /system/build.prop "ro.treble.enabled");
if [ ! "$is_treble" -o "$is_treble" == "false" ]; then
  ui_print " ";
  ui_print "Non-Treble support was dropped with Release 9";
  exit 1;
fi;

# Begin vendor changes

# Get Android version
android_version="$(file_getprop /system/build.prop "ro.build.version.release")";

if [ "$android_version" = "10" ]; then
  mount -o rw,remount -t auto /vendor >/dev/null;

  cp -rf /tmp/anykernel/patch/init.spectrum.sh /vendor/etc/init/hw/;
  rm /tmp/anykernel/ramdisk/*;
  set_perm 0 2000 0755 /vendor/etc/init/hw/init.spectrum.sh;
  
# Make a backup of init.target.rc
  restore_file /vendor/etc/init/hw/init.target.rc;
  backup_file /vendor/etc/init/hw/init.target.rc;

# Add init configuration
  append_file /vendor/etc/init/hw/init.target.rc "Ethereal" init.target.rc
fi;

rm /tmp/anykernel/patch/*;

# End vendor changes

dump_boot;

# Begin ramdisk changes
if [ "$android_version" != "10" ]; then
  insert_line init.rc "import /init.ethereal.rc" after "import /init.\${ro.zygote}.rc" "import /init.ethereal.rc";
fi
# End ramdisk changes

write_boot;
## End install