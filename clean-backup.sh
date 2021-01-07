#!/bin/sh
#
# (c) 2021 Yoichi Tanibayashi
#
MYNAME=`basename $0`
MYDIR=`dirname $0`

DRY_RUN=0

#
# functions
#
usage() {
    echo
    echo "  usage: $MYNAME [-n] DIR .."
    echo
    echo "    -n  dry run"
    echo
}

clean_dir() {
    _DIR=$1
    if [ ! -d $_DIR ]; then
        echo $_DIR is not directory .. ignored
        return 1
    fi
    
    echo [ $_DIR ]

    _SUBDIR=`ls $_DIR/backup-20[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]*`

    for _SD in $_SUBDIR; do
        if [ ! -d $_SD ]; then
            echo $_SD is not directory .. ignored
            continue
        fi

        echo $_SD
    done
    
    return 0
}

#
# main
#

YEAR=`date +'%Y'`
MONTH=`date +'%m'`

echo $YEAR/$MONTH

while getopts n OPT; do
    case $OPT in
        n) DRY_RUN=1;;
        *) usage
           exit 1
           ;;
    esac
    shift
done

echo $*

for dir in $*; do
    clean_dir $dir

done
