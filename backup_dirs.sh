#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`
LANG=ja_JP.UTF8

BACKUPSRC_FILE="backup_src.txt"
#BACKUPSRC_DIRS=". ${HOME}/etc ${HOME} /conf/etc /usr/local/etc /etc"
BACKUPSRC_DIRS="/conf/etc"

#
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME} backup_top1 [backup_top2 ..]"
    echo
}

tsecho () {
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

#
# variables
#
BACKUP_INC=/conf/etc/backup_inc.sh
tsecho "BACKUP_INC=$BACKUP_INC"
if [ ! -x ${BACKUP_INC} ]; then
    tsecho "ERROR: rsync: no such command"
    exit 1
fi

SRCDIRS=""
for d in ${BACKUPSRC_DIRS}; do
    if [ -f ${d}/${BACKUPSRC_FILE} ]; then
        tsecho "found: ${d}/${BACKUPSRC_FILE}"
        SRCDIRS=`cat ${d}/${BACKUPSRC_FILE}`
        break
    fi
done
tsecho "SRCDIRS=$SRCDIRS"
if [ -z "${SRCDIRS}" ]; then
    tsecho "${BACKUPSRC_FILE}: not found"
    exit 1
fi

SRCDIRS1=""
for s in ${SRCDIRS}; do
    if [ -d ${s} ]; then
        if [ ! -d ${s}/backups ]; then
            SRCDIRS1="${SRCDIRS1} $s"
        fi
    fi
done
SRCDIRS1=`echo ${SRCDIRS1} | sed 's/^ //'`
tsecho "SRCDIRS1=${SRCDIRS1}"

#
# args
#
BACKUP_DIRS="$*"
tsecho "BACKUPDIRS=${BACKUP_DIRS}"
if [ -z "${BACKUP_DIRS}" ]; then
    usage
    exit 1
fi

#
# main
#
for d in ${BACKUP_DIRS}; do
    CMDLINE="$BACKUP_INC ${SRCDIRS1} $d"
    tsecho "CMDLINE=$CMDLINE"
    eval $CMDLINE
done

echo
tsecho "done"
