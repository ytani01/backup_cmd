#!/bin/sh
# 
# (C) 2020 Yoichi Tanibayashi
#
############################################
# To restore
#
#   # cd ${root_dir}
#   # xzcat ${dump_file.xz} | restore -rf -
#
############################################
MYNAME=`basename $0`

DST_DIR="/private/root-dump"

DUMP_CMD="dump -0LauC 32 -f -"
COMPRESS_CMD="xz"

#
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME}"
    echo
}

tsecho () {
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}: $*"
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

##### main
TS=`LANG=C date +'%Y-%m%d-%H%M%S'`
tsecho "TS=${TS}"

DUMP_DEV=`df / | tail -1 | cut -d ' ' -f 1`
tsecho "DUMP_DEV=${DUMP_DEV}"

ROOT_DEV_NAME=`echo ${DUMP_DEV} | cut -d '/' -f 3`
tsecho "ROOT_DEV_NAME=${ROOT_DEV_NAME}"

DST_FILE="root-${ROOT_DEV_NAME}.dump.${COMPRESS_CMD}-${TS}"
tsecho "DST_FILE=${DST_FILE}"

DST_PATH="${DST_DIR}/${DST_FILE}"
tsecho "DST_PATH=${DST_PATH}"

DST_TMP="${DST_PATH}.tmp"
tsecho "DST_TMP=${DST_TMP}"

ROOT2ND_DIR="/rootdir-2nd"
tsecho "ROOT2ND_DIR=${ROOT2ND_DIR}"

if [ ! -d ${DST_DIR} ]; then
    echo ${DST_DIR}: no such directory
    exit 1
fi

tseval "${DUMP_CMD} ${DUMP_DEV} | ${COMPRESS_CMD} > ${DST_TMP}"
RET=$?
tsecho "RET=${RET}"
if [ $RET = 0 ]; then
    tseval mv -fv ${DST_TMP} ${DST_PATH}
else
    tsecho "ERROR"
fi
ls -lFh ${DST_DIR}
