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

#SRCDIRS="/boot /root /etc /home /usr/home /conf /opt /var /usr/local/www `echo /.[0-9]`"
SRCDIRS="/boot /root /etc /home /usr/home /conf /opt /var /usr/local/www"
tsecho "SRCDIRS=$SRCDIRS"

SRCDIRS1=""
for s in ${SRCDIRS}; do
    if [ -d $s ]; then
        SRCDIRS1="${SRCDIRS1} $s"
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
