#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`
#LANG=ja_JP.UTF-8

DRY_RUN=

#
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME} [-n] [[-e exclude_pattern] ..] src_dir .. backup_top"
    echo
}

tsecho () {
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

tseval() {
    _CMDLINE=$*
    tsecho eval "$_CMDLINE"
    if [ ! -z "$DRY_RUN" ]; then
        return 0
    fi
    eval "$_CMDLINE"
    _RET=$?
    if [ $_RET -ne 0 ]; then
        tsecho "error($_RET)"
        exit $_RET
    fi
    return $_RET
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
#RSYNC_CMD="LANG=en_US.UTF-8 ${RSYNC_CMD}"
RSYNC_CMD="LANG=ja_JP.UTF-8 ${RSYNC_CMD}"
#RSYNC_OPT="-avzS --delete --progress"
#RSYNC_OPT="-avS --delete --progress --inplace"
#RSYNC_OPT="-avS --delete --progress"
#RSYNC_OPT="-av --delete --progress"
RSYNC_OPT="-avS --delete"

COMPLETE_LIST="complete_list.txt"
#tsecho "COMPLETE_LIST=${COMPLETE_LIST}"

while getopts e:n OPT; do
    case $OPT in
        n) DRY_RUN=true
           RSYNC_OPT="$RSYNC_OPT -n"
           tsecho "[ DRY RUN ]"
           ;;
        e) RSYNC_OPT="$RSYNC_OPT --exclude='${OPTARG}'";;
        *) usage
           exit 1
           ;;
    esac
done
shift `expr $OPTIND - 1`

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
tseval $CMDLINE

#
# COMPLETE_LIST
#
if [ ! -z "${REMOTE}" ]; then
    tseval ssh ${REMOTE} "mv -v ${DSTDIR_INCOMPLETE} ${DSTDIR}"
    # tseval ssh ${REMOTE} "basename ${DSTDIR} >> ${BACKUP_TOP}/${COMPLETE_LIST}"
else
    tseval mv -v ${DSTDIR_INCOMPLETE} ${DSTDIR}
    # tseval "basename ${DSTDIR} >> ${BACKUP_TOP}/${COMPLETE_LIST}"
fi

tsecho "done"
echo
exit 0
