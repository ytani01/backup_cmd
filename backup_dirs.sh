#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`
LANG=ja_JP.UTF-8

BACKUPSRC_FILE="/conf/etc/backup_src.txt"

BACKUP_INC=/conf/etc/backup_inc.sh
BACKUP_OPT=

JOBS=1

#
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME} [-n] [-j jobs] [-f backup_src_file] backup_top1 [backup_top2 ..]"
    echo
}

tsecho () {
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

tseval() {
    _CMDLINE=$*
    tsecho eval "$_CMDLINE"
    eval "$_CMDLINE"
    _RET=$?
    if [ $_RET -ne 0 ]; then
        tsecho "error($_RET)"
        exit $_RET
    fi
    return $_RET
}

#
# args
#
while getopts f:j:n OPT; do
    case $OPT in
        f) if [ -f $OPTARG ]; then
               BACKUPSRC_FILE=${OPTARG}
               tsecho "BACKUPSRC_FILE=${BACKUPSRC_FILE}"
           else
               usage
               exit
           fi
           ;;
        j) if [ $OPTARG -ge 1 ]; then
               JOBS=$OPTARG
               tsecho "JOBS=$JOBS"
           else
               usage
               exit 1
           fi
           ;;
        n) BACKUP_OPT="${BACKUP_OPT} -n"
           tsecho "[ DRY RUN ]";;
        *) usage
           exit 1
           ;;
    esac
done
shift `expr $OPTIND - 1`

BACKUP_DSTS="$*"
#tsecho "BACKUP_DSTS=${BACKUP_DSTS}"
if [ -z "${BACKUP_DSTS}" ]; then
    usage
    exit 1
fi

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
    tseval ${BACKUP_INC} ${BACKUP_OPT} ${SRCDIRS1} $d
done

tsecho "done"
echo
exit 0
