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
if [ ! -x $BACKUP_INC ]; then
    tsecho "ERROR: rsync: no such command"
    exit 1
fi

#SRCDIRS="/root /etc /conf /var /usr/local/www `echo /.[0-9]`"
SRCDIRS="/root /etc /conf /var /usr/local/www"
tsecho "SRCDIRS=$SRCDIRS"

#
# args
#
BACKUP_DIRS=$*
tsecho "BACKUPDIRS=$BACKUP_DIRS"
if [ -z $BACKUP_DIRS ]; then
    usage
    exit 1
fi

#
# main
#
for d in $BACKUP_DIRS; do
    if [ ! -d $d ]; then
        tsecho "ERROR: $d: no such directory"
        continue
    fi
    CMDLINE="$BACKUP_INC $SRCDIRS $d"
    tsecho "CMDLINE=$CMDLINE"
    eval $CMDLINE
done
tsecho "done"
