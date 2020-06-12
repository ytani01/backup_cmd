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
#tsecho "RSYNC_CMD=$RSYNC_CMD"
if [ -z $RSYNC_CMD ]; then
    tsecho "ERROR: rsync: no such command"
    exit 1
fi
RSYNC_OPT="-avzS --delete"

COMPLETE_LIST="complete_list.txt"
#tsecho "COMPLETE_LIST=${COMPLETE_LIST}"

SRCDIR=""
while [ $# -gt 1 ]; do
    SRCDIR="$SRCDIR $1"
    shift
done
#tsecho "SRCDIR=$SRCDIR"
if [ -z "$SRCDIR" ]; then
    usage
    exit 1
fi

#
# args
#
BACKUP_TOP=$1
#tsecho "BACKUP_TOP=$BACKUP_TOP"

#
# REMOTE or not
#
REMOTE=""
if echo $BACKUP_TOP | grep ':' > /dev/null 2>&1; then
    REMOTE=`echo $BACKUP_TOP | sed 's/:.*$//'`
    tsecho "REMOTE=$REMOTE"

    BACKUP_TOP=`echo $BACKUP_TOP | sed 's/^.*://'`
    tsecho "BACKUP_TOP=$BACKUP_TOP"
fi

#
# PREV_BACKUP, RSYNC_OPT
#
if [ ! -z "${REMOTE}"  ]; then
    if ssh ${REMOTE} ls -d $BACKUP_TOP > /dev/null; then
        RSYNC_OPT="$RSYNC_OPT -e ssh"
        PREV_BACKUP=`ssh ${REMOTE} ls -1t $BACKUP_TOP | grep '^backup-' | head -1`
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
#tsecho "RSYNC_OPT=$RSYNC_OPT"
tsecho "PREV_BACKUP=$PREV_BACKUP"

#
# DSTDIR
#
DSTDIR_NAME="backup-`date +'%Y%m%d-%H%M%S'`"
DSTDIR="${BACKUP_TOP}/${DSTDIR_NAME}"
DSTDIR_INCOMPLETE="${DSTDIR}-incomplete"
#tsecho "DSTDIR=$DSTDIR"
#tsecho "DSTDIR=$DSTDIR_INCOMPLETE"

#
# CMDLINE and execute it
#
RSYNC_DST=${DSTDIR_INCOMPLETE}
if [ ! -z "${REMOTE}" ]; then
    RSYNC_DST="${REMOTE}:${RSYNC_DST}"
fi

if [ -z $PREV_BACKUP ]; then
    CMDLINE="$RSYNC_CMD $RSYNC_OPT $SRCDIR $RSYNC_DST"
else
    CMDLINE="$RSYNC_CMD $RSYNC_OPT --link-dest ../$PREV_BACKUP $SRCDIR $RSYNC_DST"
fi
tsecho "CMDLINE=$CMDLINE"
eval $CMDLINE
RET=$?
if [ ${RET} -eq 0 ]; then
    #
    # COMPLETE_LIST
    #
    if [ ! -z "${REMOTE}" ]; then
	ssh ${REMOTE} "mv ${DSTDIR_INCOMPLETE} ${DSTDIR}"
        ssh ${REMOTE} "basename ${DSTDIR} >> ${BACKUP_TOP}/${COMPLETE_LIST}"
    else
	mv ${DSTDIR_INCOMPLETE} ${DSTDIR}
        basename ${DSTDIR} >> ${BACKUP_TOP}/${COMPLETE_LIST}
    fi
fi

echo
tsecho "done(${RET})"
exit ${RET}
