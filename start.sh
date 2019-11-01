#!/bin/bash

APPID=294420
FLAGFILE=/data/.upgrade_flag
steamcmd=/home/steam/steamcmd/steamcmd.sh

if [ ! -d /data/overrides ];then
    echo "Creating overrides directory."
    echo "Copy customized files from /data into /data/overides"
    echo "keeping the subpath intact. These files will replace"
    echo "game updates from Steam."
    mkdir /data/overrides
fi

if [ -f ${FLAGFILE} ] && [ "${CHECK_UPDATE}" != "0" ];then
    echo "CHECK_UPDATE enabled, clearing update flag..."
    rm -f ${FLAGFILE}
fi

if [ -f ${FLAGFILE} ];then
    echo "Found flag file ${FLAGFILE}. Skipping steam client install/upgrade check."
else
    echo "Installing/upgrading steam client..."
    $steamcmd +quit
    echo -e "\n"
fi

if [ -f ${FLAGFILE} ];then
    echo "Found flag file ${FLAGFILE}. Skipping game server install/upgrade check."
else
    if [ "${CONFIG_FILE}" = "/data/serverconfig.xml" ] && [ -f /data/serverconfig.xml ];then
        echo "Backing up ${CONFIG_FILE} into overrides..."
        cp /data/serverconfig.xml /data/overrides/serverconfig.xml
    fi

    echo "Installing/upgrading game server..."
    $steamcmd \
        +login anonymous \
        +force_install_dir /data \
        +app_update ${APPID} validate \
        +quit
    echo -e "\n"
fi

[ "${CHECK_UPDATE}" = "0" ] && touch ${FLAGFILE}

if [ "${CONFIG_FILE}" != "/data/serverconfig.xml" ] && [ ! -f "${CONFIG_FILE}" ];then
    echo "Custom config file ${CONFIG_FILE} not found!" >&2
    exit 1
fi

if [ "${CONFIG_FILE}" = "/data/serverconfig.xml" ] && [ ! -f "${CONFIG_FILE}" ];then
    echo "Default config file not found. It will be created on"
    echo "the first startup. Stop the server after the first startup"
    echo "and edit ${CONFIG_FILE} with your local customizations."
fi

echo "Syncing override files..."
rsync -av /data/overrides/ /data/ --exclude overrides/

/data/7DaysToDieServer.x86_64 \
  -logfile /dev/stdout \
  -configfile=${CONFIG_FILE} \
  -quit \
  -batchmode \
  -nographics \
  -dedicated
