#!/bin/sh
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
echo OLD_DAY1=$OLD_DAY1
echo OLD_DAY2=$OLD_DAY2

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

        if [ $d1 -gt $OLD_DAY1 ]; then
            # OLD_DAY1 より新しい .. 残す
            echo "# $d"

        # OLD_DAY1 以前
        elif [ `expr $d1 % 2` -eq 0 ]; then
            # 日付が偶数 .. 削除
            echo "X $d"

        # OLD_DAY1 以前、日付が奇数
        elif [ $d1 -gt $OLD_DAY2 ]; then
            # OLD_DAY2 より新しい .. 残す
            echo "# $d"

        # OLD_DAY2 以前、日付が奇数
        elif [ `echo $d1 | sed 's/^......//'` = "31" ]; then
            # 31日 .. 削除
            echo "X $d"

        # OLD_DAY2 以前、日付が奇数、31日以外
        elif [ `echo $d1 | sed 's/^.......//'` = "1" ]; then
            # 日付の末尾が「1」 .. 残す
            echo "# $d"

        # OLD_DAY2 以前、日付の末尾が「1」以外
        else
            echo "X $d"
        fi
    done

    rm -f $_BACKUP_DIRS
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

    if [ $DRY_RUN -ne 1 ]; then
        sudo sh -x $RM_SCRIPT
    else
        cat $RM_SCRIPT
    fi

    rm -f $RM_SCRIPT
done
