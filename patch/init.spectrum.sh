#!/system/bin/sh
if [ "`getprop persist.spectrum.profile`" == "" ]; then
    setprop persist.spectrum.profile 0
fi

