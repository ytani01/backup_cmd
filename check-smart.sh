#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`

SMARTCTL_ALL_CMD="smartctl -a"
SMARTCTL_TEST_RESULT_CMD="smartctl -l selftest"

KEYWD_MODEL_FAMILY="Model Family"
KEYWD_DEV_MODEL="Device Model"
KEYWD_FW_VAR="Firmware Version"

KEYWD_ATTR_POWERON="Power_On_Hours"
KEYWD_ATTR_TEMP="Temperature_Celsius"
KEYWD_ATTR_REALLOCATE_CT="Reallocated_Sector_Ct"
KEYWD_ATTR_PENDING_SECTOR="Current_Pending_Sector"
KEYWD_ATTR_UNCORRECTABLE="Offline_Uncorrectable"

usage() {
    echo
    echo "    usage: ${MYNAME} [/dev/]dev_name"
    echo
}

tsecho() {
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

tseval() {
    _CMDLINE=$*
    tsecho eval "$_CMDLINE"
    eval "$_CMDLINE"
    _RET=$?
    if [ $_RET -ne 0 -a $_RET -ne 128 $_RET -ne 192 ]; then
        tsecho "error($_RET)"
        exit $_RET
    fi
    return $_RET
}

out_info() {
    _LINE=`eval "grep '$1' $2"`
    echo $_LINE
}

out_attr() {
    _LINE1=`eval "grep '$1' $2" | sed 's/^ //'`
    #tsecho "_LINE1=$_LINE1"

    _LINE2=`echo ${_LINE1} | cut -d ' ' -f 2,10`
    #tsecho "_LINE2=$_LINE2"

    echo $_LINE2
}

check_smart() {
    if [ -z $1 ]; then
	usage
	exit 1
    fi
    if echo $1 | grep ^/dev/ > /dev/null 2>&1; then
	_DEV=$1
    else
	_DEV="/dev/$1"
    fi
    if [ ! -c ${_DEV} -a ! -b ${_DEV} ]; then
        tsecho "ERROR: ${_DEV}: no such device"
        exit 1
    fi
    
    _OUT=`mktemp`
    sudo ${SMARTCTL_ALL_CMD} ${_DEV} > ${_OUT}

    echo $_DEV
    echo "====================================="
    out_info "${KEYWD_MODEL_FAMILY}" ${_OUT}
    out_info "${KEYWD_DEV_MODEL}" ${_OUT}
    out_info "${KEYWD_FW_VAR}" ${_OUT}
    echo "-------------------------------------"
    out_attr "${KEYWD_ATTR_POWERON}" ${_OUT}
    out_attr "${KEYWD_ATTR_TEMP}" ${_OUT}
    echo "-------------------------------------"
    out_attr "${KEYWD_ATTR_REALLOCATE_CT}" ${_OUT}
    out_attr "${KEYWD_ATTR_PENDING_SECTOR}" ${_OUT}
    out_attr "${KEYWD_ATTR_UNCORRECTABLE}" ${_OUT}
    echo "====================================="
    echo

    rm -f ${_OUT}

    sudo ${SMARTCTL_TEST_RESULT_CMD} ${_DEV}
    _RC=$?
    echo "_RC=$_RC"
    return $_RC
}

### main
check_smart $1
exit $?
