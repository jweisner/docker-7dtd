#!/bin/bash

APPID=294420
FLAGFILE=/data/.upgrade_flag
steamcmd=/home/steam/steamcmd/linux32/steamcmd

if [ -f ${FLAGFILE} ];then
    echo "Found flag file ${FLAGFILE}. Skipping install/upgrade check."
else
    $steamcmd \
        +login anonymous \
        +force_install_dir /data \
        +app_update $APPID validate \
        +quit
fi

/data/7DaysToDieServer.x86_64 \
  -logfile /dev/stdout \
  -configfile=$CONFIG_FILE \
  -quit \
  -batchmode \
  -nographics \
  -dedicated
