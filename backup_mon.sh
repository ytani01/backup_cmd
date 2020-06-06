#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`
LANG=ja_JP.UTF8

DEF_INTERVAL=10
DEBUG="off"

#
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME} [-i interval_sec(default:10)] pattern"
    echo
}

tsecho () {
    if [ ${DEBUG} != "on" ]; then
        return
    fi
    
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

get_temp_rpi () {
    t1=`cat /sys/class/thermal/thermal_zone0/temp`
    t2=`expr \( $t1 + 50 \) / 100`
    t3=`echo $t2 | sed 's/\(.\)$/\.\1/'`
    echo $t3
}

get_temp_freebsd () {
    echo TBD
}

#
# args
#
INTERVAL=$DEF_INTERVAL
DEBUG=off
while getopts di: OPT; do
    case $OPT in
        i) expr $OPTARGS + 1 > /dev/null 2>&1
           if [ $? != 0 ]; then
               usage
               exit 1
           fi

           if [ $OPTARG -le 0 ]; then
               usage
               exit 1
           fi
           
           INTERVAL=$OPTARG
           shift
           ;;
        
        d) DEBUG="on"
           ;;

        *) usage
           exit 1
           ;;
    esac
    shift
done
tsecho "INTERVAL=$INTERVAL"

tsecho $#
if [ $# != 1 ]; then
    usage
    exit 1
fi

PATTERN=$1
tsecho "PATTERN=$PATTERN"

PREV_MB=-1
while true; do
    DFLINE=`df -m | grep ${PATTERN} | wc -l`
    tsecho "DFLINE=$DFLINE"
    if [ $DFLINE -ne 1 ]; then
        echo
        echo "ambiguous pattern: ${PATTERN}"
        echo
        df -m | grep ${PATTERN}
        echo
        exit 2
    fi

    MB=`df -m | grep ${PATTERN} | sed 's/  */:/g' | cut -d: -f3`

    DFLINE=`df -h | grep ${PATTERN}`
    TOTAL=`echo $DFLINE | sed 's/  */:/g' | cut -d: -f2`
    AVAIL=`echo $DFLINE | sed 's/  */:/g' | cut -d: -f4`
    
    D_MB=`expr ${MB} - ${PREV_MB}`
    if [ ${D_MB} -gt 0 ]; then
        D_MB="+${D_MB}"
    fi
    tsecho "PREV_MB=$PREV_MB MB=$MB D_MB=$D_MB"

    UNAME=`uname`
    tsecho "UNAME=$UNAME"
    if [ $UNAME = "Linux" ]; then
        TEMP=`get_temp_rpi`
    elif [ $UNAME = "FreeBSD" ]; then
        TEMP=`get_temp_freebsd`
    else
        TEMP="no temperature"
    fi

    TS=`date +'%H:%M:%S'`

    if [ ${PREV_MB} -ge 0 ]; then
        echo "$TS  ${D_MB}[MB]/${INTERVAL}[sec]  ${AVAIL}/${TOTAL}  Temp=$TEMP"
    fi

    PREV_MB=$MB
    sleep ${INTERVAL}
done

