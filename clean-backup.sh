#!/bin/sh -e
#
# (c) 2021 Yoichi Tanibayashi
#
MYNAME=`basename $0`
MYDIR=`dirname $0`
OS_NAME=`uname -o`

DRY_RUN=0
BACKUP_PREFIX="backup-"

if [ $OS_NAME = "FreeBSD" ]; then
    OLD_DAY1=`date -v -1m +'%Y%m%d'`
    OLD_DAY2=`date -v -4m +'%Y%m%d'`
else
    OLD_DAY1=`date --date "last month" +'%Y%m%d'`
    OLD_DAY2=`date --date "4 month ago" +'%Y%m%d'`
fi
echo $OLD_DAY1 $OLD_DAY2

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

get_date() {
    _DIRNAME=$1

    echo $_DIRNAME | sed 's/^.*backup-//' | sed 's/-......$//'
}

set_OX() {
    _DIR=$1
    if [ ! -d $_DIR ]; then
        echo $_DIR is not directory .. ignored
        return 1
    fi
    
    echo [ $_DIR ]

    _BACKUP_DIRS=`mktemp /tmp/$MYNAME-XXX`

    ls -d $_DIR/backup-20[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]* > $_BACKUP_DIRS

    for d in `cat $_BACKUP_DIRS`; do
        d1=`get_date $d`
        #echo d1 = $d1
        if [ $d1 -gt $OLD_DAY1 ]; then
            echo "# $d"
        elif [ `expr $d1 % 2` -eq 0 ]; then
            echo "X $d"
        elif [ $d1 -gt $OLD_DAY2 ]; then
            echo "# $d"
        elif [ `echo $d1 | sed 's/^......//'` = "31" ]; then
            echo "X $d"
        elif [ `echo $d1 | sed 's/^.......//'` = "1" ]; then
            echo "# $d"
        else
            echo "X $d"
        fi
    done

    rm -fv $_BACKUP_DIRS
    return 0
}

#
# main
#
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
    RM_SCRIPT=`mktemp /tmp/$MYNAME-XXX.sh`
    set_OX $dir | sed 's/^O/#/' | sed 's/^X/rm -rf /' > $RM_SCRIPT

    sudo sh -x $RM_SCRIPT
    rm -fv $RM_SCRIPT
done
