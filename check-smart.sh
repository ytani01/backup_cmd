#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`

SMARTCTL_ALL_CMD="smartctl -a"
SMARTCTL_TEST_RESULT_CMD="smartctl -l selftest"

KEYWD_MODEL_FAMILY="Model Family"
KEYWD_DEV_MODEL="Device Model"
KEYWD_DEV_SNO="Serial Number"
KEYWD_FW_VAR="Firmware Version"

KEYWD_ATTR_POWERON="Power_On_Hours"
KEYWD_ATTR_TEMP="Temperature_Celsius"
KEYWD_ATTR_REALLOCATE_CT="Reallocated_Sector_Ct"
KEYWD_ATTR_PENDING_SECTOR="Current_Pending_Sector"
KEYWD_ATTR_UNCORRECTABLE="Offline_Uncorrectable"

OPT_TEST=

usage() {
    echo
    echo "    usage: ${MYNAME} [-t] [/dev/]dev_name"
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

    _TITLE=`echo ${_LINE1} | cut -d ' ' -f 2`
    _VALUE=`echo ${_LINE1} | cut -d ' ' -f 10`
    _RAW_VALUE=$_VALUE
    _UNIT="hours"

    if [ $_TITLE = $KEYWD_ATTR_POWERON ]; then
        if [ `echo "$_VALUE > 24" | bc` -eq 1 ]; then
            _VALUE=`echo "scale=1; ${_VALUE} / 24" | bc`
            _UNIT="days"
            if [ `echo "$_VALUE > 365" | bc` -eq 1 ]; then
                _VALUE=`echo "scale=1; ${_VALUE} / 365" | bc`
                _UNIT="years"
            fi
        fi
        _VALUE="$_RAW_VALUE ($_VALUE $_UNIT)"
    fi

    echo ${_TITLE}: ${_VALUE}
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
    _RC=$?

    echo "====================================="
    echo $_DEV
    for d in /dev/gpt /dev/disk/by-partlabel; do
	if [ -d $d ]; then
	    LANG=C ls -l $d | grep `basename $_DEV` | sed 's/  */ /g' | cut -d ' ' -f 9-
	fi
    done

    echo "====================================="
    out_info "${KEYWD_MODEL_FAMILY}" ${_OUT}
    out_info "${KEYWD_DEV_MODEL}" ${_OUT}
    out_info "${KEYWD_DEV_SNO}" ${_OUT}
    out_info "${KEYWD_FW_VAR}" ${_OUT}
    echo "-------------------------------------"
    out_attr "${KEYWD_ATTR_POWERON}" ${_OUT}
    out_attr "${KEYWD_ATTR_TEMP}" ${_OUT}
    echo "-------------------------------------"
    out_attr "${KEYWD_ATTR_REALLOCATE_CT}" ${_OUT}
    out_attr "${KEYWD_ATTR_PENDING_SECTOR}" ${_OUT}
    out_attr "${KEYWD_ATTR_UNCORRECTABLE}" ${_OUT}
    echo "====================================="

    rm -f ${_OUT}

    if [ -z "$OPT_TEST" ]; then
	echo "_RC=$_RC"
	echo "====================================="
	return $_RC
    fi

    sudo ${SMARTCTL_TEST_RESULT_CMD} ${_DEV}
    _RC=$?
    echo "====================================="
    echo "_RC=$_RC"
    echo "====================================="
    return $_RC
}

### main
while getopts t OPT; do
    case $OPT in
        t) OPT_TEST="-t";;
        *) usage
           exit 1
           ;;
    esac
done
shift `expr $OPTIND - 1`

check_smart $1
exit $?
