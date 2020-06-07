#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
LANG=ja_JP.UTF8
MYNAME=`basename $0`

BACKUP_DIR_PATTERN="backup-????????-??????"
COMPLETE_LIST_FILE="complete_list.txt"

#
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME} backup_top"
    echo
}

tsecho () {
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

#
#
#
if [ $# -ne 1 ]; then
    usage
    exit 1
fi

BACKUP_TOP=$1
tsecho "BACKUP_TOP=${BACKUP_TOP}"
if [ ! -d ${BACKUP_TOP} ]; then
    tsecho "${BACKUP_TOP}: no such directory"
    exit 1
fi

cd ${BACKUP_TOP}

BACKUP_DIRS=`eval echo ${BACKUP_DIR_PATTERN}`
tsecho "BACKUP_DIRS=${BACKUP_DIRS}"
if [ "${BACKUP_DIRS}" = "${BACKUP_DIR_PATTERN}" ]; then
    tsecho "no backup dirs"
    exit 1
fi
if [ ! -f ${COMPLETE_LIST_FILE} ]; then
    tsecho "${COMPLETE_LIST_FILE}; no such file"
    exit 1
fi

COMPLETE_DIRS=`cat ${COMPLETE_LIST_FILE}`
tsecho "COMPLETE_DIRS=${COMPLETE_DIRS}"

INCOMPETE_DIRS=""
for d1 in ${BACKUP_DIRS}; do
    COMP_FLAG=0
    for d2 in ${COMPLETE_DIRS}; do
        if [ ${d1} = ${d2} ]; then
            COMP_FLAG=1
            break
        fi
    done
    if [ $COMP_FLAG -eq 1 ]; then
        tsecho "${d1} .. skip"
        continue
    fi
    INCOMPETE_DIRS="${INCOMPETE_DIRS} ${d1}"
done
LAST_BACKUP_DIR=${d1}
tsecho "INCOMPETE_DIRS=${INCOMPETE_DIRS}"
tsecho "LAST_BACKUP_DIR=${LAST_BACKUP_DIR}"

for d in ${INCOMPETE_DIRS}; do
    if [ $d == ${LAST_BACKUP_DIR} ]; then
        break
    fi
    CMDLINE="rm -rfv ${d}"
    tsecho "CMDLINE=${CMDLINE}"
    eval ${CMDLINE}
done
