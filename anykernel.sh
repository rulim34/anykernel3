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

# ROM Check
rom_version="$(file_getprop /system/build.prop "org.pixelexperience.version")";
if [ ! "$rom_version" = "10" ]; then
  ui_print " ";
  ui_print "This kernel was built specifically for PixelExperience 10";
  exit 1;
fi;

# Begin vendor changes
  mount -o rw,remount -t auto /vendor >/dev/null;

  cp -rf /tmp/anykernel/patch/init.spectrum.sh /vendor/etc/init/hw/;
  rm /tmp/anykernel/ramdisk/*;
  set_perm 0 2000 0755 /vendor/etc/init/hw/init.spectrum.sh;
  
# Make a backup of init.target.rc
  restore_file /vendor/etc/init/hw/init.target.rc;
  backup_file /vendor/etc/init/hw/init.target.rc;

# Add init configuration
  append_file /vendor/etc/init/hw/init.target.rc "Ardadedali+" init.target.rc

rm /tmp/anykernel/patch/*;

# End vendor changes

dump_boot;

write_boot;
## End install