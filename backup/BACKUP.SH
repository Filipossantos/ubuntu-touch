#!/bin/sh			
# Backup Ubuntu Device Script created by https://github.com/popey/buds edited by Filip Michalski
# Goal: backup all user data and a list of apps
# todo: Restore script ;) (SEARCH ON UBPORTS FORUM)
if [ "$#" -ne 1 ]; then
    echo "Specify password/passphrase"
    exit 1
fi
CWD=$(pwd)
DATESTART=$(date +%Y%m%d-%H%M%S)
#BACKUPDIR=/media/phablet/367AF0BF7AF07D45/backup/$DATESTART
BACKUPDIR=$CWD/backup/$DATESTART
LOGFILE=$BACKUPDIR/backup.log
CLICKFILE=$BACKUPDIR/clicks.list
DEVICEUSER="phablet"
PASSPHRASE="$1"
# Create directory for backup and log
mkdir -p $BACKUPDIR
if [ "$?" -ne "0" ]; then
  echo "Failed to create $BACKUPDIR"
  exit 5
fi
log(){ echo $(date +%Y%m%d-%H%M%S) : $* | tee -a $LOGFILE; }
# TODO HERE
# Check we have the tools we need to run the backup (rsync / tee)
# Get device code name
log "Get device code name"
DEVICENAME=$(getprop ro.product.name)
if [ "$DEVICENAME" = "" ]; then
  log "Failed to get device code name"
  exit 1
fi
log "Got device code name: $DEVICENAME"

# Get device serial number
log "Get device serial number"
DEVICESERIAL=$(getprop ro.serialno)
if [ "$DEVICESERIAL" = "" ]; then
  log "Failed to get device serial number"
  exit 2
fi
log "Got device serial number: $DEVICESERIAL"
log "Determine disk space used on device"
DEVICESPACE=$(echo $PASSPHRASE | sudo -S --prompt='' du -bks /home/phablet/ | awk '{ print $1}')
log "Finished determining disk space used on device"

log "Determine free space on current machine"
DESKTOPSPACE=$(df -k $BACKUPDIR | tail -n 1 | awk '{ print $4}')
log "Finished determining free space on current machine"

# Check if we have enough disk space in $BACKUPDIR for the backup (roughly same size)
log "Approximate disk space used on device (K): $DEVICESPACE"
log "Approximate free space on backup disk (K): $DESKTOPSPACE"

# Rudimentary check for same space used on device on desktop
if [ "$DEVICESPACE" -gt "$DESKTOPSPACE" ]; then
  log "Insufficient free space on backup device: $DESKTOPSPACE smaller than $DEVICESPACE"
  exit 3
fi

# Get list of applications installed on device
log "Get list of installed apps from device"
click list > $CLICKFILE
log "Finished getting list of installed apps from device"

# Start backup
log "Copying files from device"
cp -a /home/phablet/. $BACKUPDIR

if [ "$?" = "0" ]; then
  log "Finished copying files from device to $COMPRESSEDBACKUP"
else
  log "Copying files from device FAILED"
  exit 4
fi
