#!/bin/sh
# 
# Yoichi Tanibayashi
#
# To restore
#
#   # cd ${root_dir}
#   # xzcat ${dump_file.xz} | restore -rf -
#
MYNAME=`basename $0`

DST_DIR="/private/root-dump"

ROOT_DEV_NAME=`df / | tail -1 | sed 's/ .*$//' | sed 's/^\/dev\///'`

DUMP_CMD="dump -0Lauf -"
COMPRESS_CMD="xz"

DUMP_DEV="/dev/${ROOT_DEV_NAME}"
DST_FILE="root-${ROOT_DEV_NAME}.dump.${COMPRESS_CMD}"
DST_PATH="${DST_DIR}/${DST_FILE}"
DST_TMP="${DST_PATH}.tmp"

CMDLINE="${DUMP_CMD} ${DUMP_DEV} | ${COMPRESS_CMD} > ${DST_TMP}"

##### func
echo_and_call () {
    echo $*
    sh -c "$*"
}

rotate () {
    FILE=$1
    MAX=$2

    I=${MAX}
    while [ ${I} -gt 0 ]; do
        J=`expr ${I} - 1`

	SRC="${FILE}.${J}"
	DST="${FILE}.${I}"

	if [ -f ${SRC} ]; then
	    echo_and_call "mv ${SRC} ${DST}"
	fi

	I=${J}
    done 

    if [ -f ${FILE} ]; then
	echo_and_call "mv ${FILE} ${FILE}.0"
    fi
}
##### main
if [ ! -d ${DST_DIR} ]; then
    echo ${DST_DIR}: no such directory
    exit 1
fi

#echo_and_call touch ${DST_TMP}
echo_and_call ${CMDLINE}

RET=$?
echo "RET=${RET}"
if [ $RET = 0 ]; then
    rotate ${DST_PATH} 3
    echo_and_call mv ${DST_TMP} ${DST_PATH}
fi
ls -lFh ${DST_DIR}
