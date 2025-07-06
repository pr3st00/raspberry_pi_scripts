#!/bin/bash

ROMS_ORIGIN_DIR="/recalbox/share/externals/usb0/Backups/Devices/Recalbox/roms"
RECALBOX_ROM_DIR="/recalbox/share/roms"
LOG_FILE="alreadycopied.log"

echo "[INI] Recalbox ROM transfer script."
echo ""
echo "[WARNING] This process will copy roms from the usb drive to recalbox, press any key to start"
echo ""
echo "SOURCE_DIR = $ROMS_ORIGIN_DIR"
echo "DEST_DIR   = $RECALBOX_ROM_DIR"
echo ""
read

touch $LOG_FILE

for DIR in $(ls $ROMS_ORIGIN_DIR)
do 
	if egrep -q "^$DIR$" $LOG_FILE; 
	then 
		echo "[INFO] Skipping $DIR, already copied."; 
	elif [[ -d $RECALBOX_ROM_DIR/$DIR ]]; then
		echo "[INFO] Copying $DIR, please wait..."; 
		cp -R $ROMS_ORIGIN_DIR/$DIR/* $RECALBOX_ROM_DIR/$DIR;
		sleep 5
		echo $DIR >> $LOG_FILE
	else
		echo "[WARNING] Rom directory $DIR not found, copying to pending dir"
		mkdir "$RECALBOX_ROM_DIR/pending/$DIR"
		cp -R $ROMS_ORIGIN_DIR/$DIR/* "$RECALBOX_ROM_DIR/pending/$DIR";
	fi
done

echo "[DONE] Completed sucessfully"

# EOF
