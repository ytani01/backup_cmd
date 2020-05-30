#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`

LANG=ja_JP.UTF8

RSYNC_CMD="rsync"
RSYNC_OPT="-avzS --delete"

#
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME} src_dir .. backup_top"
    echo
}

tsecho () {
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

#
# args
#
SRCDIR=""
while [ $# -gt 1 ]; do
    SRCDIR="$SRCDIR $1"
    shift
done
tsecho "SRCDIR=$SRCDIR"
if [ -z "$SRCDIR" ]; then
    usage
    exit 1
fi

BACKUP_TOP=$1
tsecho "BACKUP_TOP=$BACKUP_TOP"
if [ ! -d $BACKUP_TOP ]; then
    tsecho "ERROR: $BACKUP_TOP: no such directory"
    usage
    exit 1
fi

#
# main
#
PREV_BACKUP=`ls -1t ${BACKUP_TOP} | head -1`
tsecho "PREV_BACKUP=$PREV_BACKUP"

DSTDIR="${BACKUP_TOP}/backup-`date +'%Y%m%d-%H%M%S'`"
tsecho "DSTDIR=$DSTDIR"

if [ -z $PREV_BACKUP ]; then
    CMDLINE="$RSYNC_CMD $RSYNC_OPT $SRCDIR $DSTDIR"
else
    CMDLINE="$RSYNC_CMD $RSYNC_OPT --link-dest ../$PREV_BACKUP $SRCDIR $DSTDIR"
fi
tsecho "CMDLINE=$CMDLINE"

exec $CMDLINE
