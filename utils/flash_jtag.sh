#!/bin/sh
topdir=$((dirname $(readlink -f $0))
$topdir/bin/openocd -f scripts/interface/ftdi/flyswatter2.cfg -f scripts/board/firestarter.cfg -f scripts/codk-jtag.cfg
if [ $? -ne 0 ]; then
  echo
  echo "***ERROR***"
  exit 1
else
  echo
  echo "!!!SUCCESS!!!"
fi
