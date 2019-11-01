#!/bin/bash

APPID=294420
FLAGFILE=$HOME/.upgrade_flag
OVERRIDES=$HOME/overrides
SERVERBASE=$HOME/7dtd
steamcmd=$HOME/steamcmd.sh
SAVEDIR=$HOME/.local/share/7DaysToDie/Saves

if [ ! -d $OVERRIDES ];then
    echo "Creating overrides directory. Copy customized files from $SERVERBASE into $OVERRIDES keeping the subpath intact. These files will replace game updates from Steam." | fold -w 80 -s
    mkdir $OVERRIDES
fi

if [ -f ${FLAGFILE} ] && [ "${CHECK_UPDATE}" != "0" ];then
    echo "CHECK_UPDATE enabled, clearing update flag..."
    rm -f ${FLAGFILE}
fi

if [ -f ${FLAGFILE} ];then
    echo "Found flag file ${FLAGFILE}. Skipping steam client install/upgrade check." | fold -w 80 -s
else
    echo "Installing/upgrading steam client..."
    $steamcmd +quit
    echo -e "\n"
fi

if [ -f ${FLAGFILE} ];then
    echo "Found flag file ${FLAGFILE}. Skipping game server install/upgrade check." | fold -w 80 -s
else
    if [ -f "$SERVERBASE/serverconfig.xml" ];then
        echo "Backing up serverconfig.xml into overrides..."
        cp "$SERVERBASE/serverconfig.xml" $OVERRIDES/serverconfig.xml
    fi

    echo "Installing/upgrading game server..."
    $steamcmd \
        +login anonymous \
        +force_install_dir $SERVERBASE \
        +app_update ${APPID} validate \
        +quit
    echo -e "\n"
fi


[ "${CHECK_UPDATE}" = "0" ] && touch ${FLAGFILE}

if [ ! -f "$SERVERBASE/serverconfig.xml" ];then
    echo "Default config $SERVERBASE/serverconfig.xml file not found. It will be created on the first startup. Stop the server after the first startup and edit $OVERRIDES/serverconfig.xml with your local customizations." | fold -w 80 -s
fi

if [ ! -f "$SAVEDIR/serveradmin.xml" ];then
    echo "Default admin file $SAVEDIR/serveradmin.xml not found. It will be created on the first startup. Stop the server after the first startup and edit $SAVEDIR/serverconfig.xml with your local customizations." | fold -w 80 -s
fi

echo "Syncing override files..."
rsync -av $OVERRIDES/ $SERVERBASE/

LD_LIBRARY_PATH=/home/steam/linux64 "$SERVERBASE/7DaysToDieServer.x86_64" \
  -logfile /dev/stdout \
  -configfile="$SERVERBASE/serverconfig.xml" \
  -quit \
  -batchmode \
  -nographics \
  -dedicated
