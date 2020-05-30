#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`

LANG=ja_JP.UTF8

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
# variables
#
RSYNC_CMD=`which rsync`
tsecho "RSYNC_CMD=$RSYNC_CMD"
if [ -z $RSYNC_CMD ]; then
    tsecho "ERROR: rsync: no such command"
    exit 1
fi
RSYNC_OPT="-avzS --delete"

COMPLETE_LIST="complete_list.txt"
tsecho "COMPLETE_LIST=${COMPLETE_LIST}"

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

REMOTE=""
if echo $BACKUP_TOP | grep ':' > /dev/null 2>&1; then
    REMOTE=`echo $BACKUP_TOP | sed 's/:.*$//'`
    tsecho "REMOTE=$REMOTE"

    BACKUP_RDIR=`echo $BACKUP_TOP | sed 's/^.*://'`
    tsecho "BACKUP_RDIR=$BACKUP_RDIR"
fi

if [ ! -z "${REMOTE}"  ]; then
    if ssh ${REMOTE} ls -d $BACKUP_RDIR > /dev/null; then
        RSYNC_OPT="$RSYNC_OPT -e ssh"
        PREV_BACKUP=`ssh ${REMOTE} ls -1t $BACKUP_RDIR | grep '^backup-' | head -1`
    else
        tsecho "ERROR: ${REMOTE}:$BACKUP_DIR: invalid directory"
        usage
        exit 1
    fi 
else
    if [ -d $BACKUP_TOP ]; then
        PREV_BACKUP=`ls -1t ${BACKUP_TOP} | grep '^backup-' | head -1`
    else
        tsecho "ERROR: $BACKUP_TOP: no such directory"
        usage
        exit 1
    fi
fi
tsecho "RSYNC_OPT=$RSYNC_OPT"
tsecho "PREV_BACKUP=$PREV_BACKUP"

DSTDIR="${BACKUP_TOP}/backup-`date +'%Y%m%d-%H%M%S'`"
tsecho "DSTDIR=$DSTDIR"

if [ -z $PREV_BACKUP ]; then
    CMDLINE="$RSYNC_CMD $RSYNC_OPT $SRCDIR $DSTDIR"
else
    CMDLINE="$RSYNC_CMD $RSYNC_OPT --link-dest ../$PREV_BACKUP $SRCDIR $DSTDIR"
fi
tsecho "CMDLINE=$CMDLINE"

eval $CMDLINE
if [ $? -eq 0 ]; then
    if [ ! -z "${REMOTE}" ]; then
        ssh ${REMOTE} "echo ${DSTDIR} >> ${BACKUP_RDIR}/${COMPLETE_LIST}"
    else
        echo ${DSTDIR} >> ${BACKUP_TOP}/${COMPLETE_LIST}
    fi
fi

echo
tsecho "done"
