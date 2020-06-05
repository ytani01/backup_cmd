#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`
LANG=ja_JP.UTF8

BACKUPSRC_FILE="/conf/etc/backup_src.txt"

#
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME} [-f backup_src_file] backup_top1 [backup_top2 ..]"
    echo
}

tsecho () {
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

#
# args
#
while getopts f: OPT; do
    case $OPT in
        f) if [ ! -z "OPTARG" ]; then
               BACKUPSRC_FILE=${OPTARG}
               shift
           fi;;
        *) usage
           exit 1;;
    esac
    shift
done

BACKUP_DSTS="$*"
#tsecho "BACKUP_DSTS=${BACKUP_DSTS}"
if [ -z "${BACKUP_DSTS}" ]; then
    usage
    exit 1
fi

#
# variables
#
BACKUP_INC=/conf/etc/backup_inc.sh
#tsecho "BACKUP_INC=$BACKUP_INC"
if [ ! -x ${BACKUP_INC} ]; then
    tsecho "ERROR: rsync: no such command"
    exit 1
fi

SRCDIRS=""
if [ -f ${BACKUPSRC_FILE} ]; then
    #tsecho "found: ${BACKUPSRC_FILE}"
    SRCDIRS0=`cat ${BACKUPSRC_FILE}`
    #tsecho "SRCDIRS0=${SRCDIRS0}"
    SRCDIRS=`eval echo ${SRCDIRS0}`
fi
#tsecho "SRCDIRS=$SRCDIRS"
if [ -z "${SRCDIRS}" ]; then
    tsecho "${BACKUPSRC_FILE}: not found"
    exit 1
fi

SRCDIRS1=""
for s in ${SRCDIRS}; do
    if [ -d ${s} ]; then
        SRCDIRS1="${SRCDIRS1} $s"
    fi
done
SRCDIRS1=`echo ${SRCDIRS1} | sed 's/^ //'`
#tsecho "SRCDIRS1=${SRCDIRS1}"

#
# main
#
for d in ${BACKUP_DSTS}; do
    CMDLINE="$BACKUP_INC ${SRCDIRS1} $d"
    tsecho "CMDLINE=$CMDLINE"
    eval $CMDLINE
done

echo
tsecho "done"
