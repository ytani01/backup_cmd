#!/bin/sh
#
# Copyright (c) 2023 Yoichi Tanibayashi
#
MYNAME=`basename $0`
MYDIR=`dirname $0`

DRY_RUN=0
VERBOSE=""

OS_NAME=`uname -o`
BACKUP_DIR_PREFIX="backup"

#
# functions
#
usage () {
    echo
    echo "$MYNAME -nv "
    echo
}

#
# main
#
### parse options
while getopts nv OPT; do
    case $OPT in
        n) DRY_RUN=1;;
        v) VERBOSE=true
           RM_OPT_V="-v"
           ;;
        *) usage
           exit 1
           ;;
    esac
done
shift `expr $OPTIND - 1`

$VERBOSE && echo \$\*=$*

### old days
if [ $OS_NAME = "FreeBSD" ]; then
    OLD_DAY1=`date -v -1m +'%Y%m%d'`
    OLD_DAY2=`date -v -3m +'%Y%m%d'`
    OLD_DAY3=`date -v -y1 +'%Y%m%d'`
else
    OLD_DAY1=`date --date "last month" +'%Y%m%d'`
    OLD_DAY2=`date --date "3 month ago" +'%Y%m%d'`
    OLD_DAY3=`date --date "1 year ago" +'%Y%m%d'`
fi

$VERBOSE && echo OLD_DAY1=$OLD_DAY1
$VERBOSE && echo OLD_DAY2=$OLD_DAY2
$VERBOSE && echo OLD_DAY3=$OLD_DAY3

for dir in $*; do
    $VERBOSE && echo "=========="
    $VERBOSE && echo "dir=$dir"

    if [ ! -d $dir ]; then
        echo ERROR: $dir is not a directory .. ignored
        continue
    fi

    BACKUP_DIRS_FILE=`mktemp /tmp/$MYNAME-XXX.sh`
    $VERBOSE && echo BACKUP_DIRS_FILE=$BACKUP_DIRS_FILE
    $VERBOSE && echo RM_OPT_V=$RM_OPT_V

     ls -d ${dir}/${BACKUP_DIR_PREFIX}-20[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]* > $BACKUP_DIRS_FILE
    
    continue
    
    set_OX $dir | sed 's/^O/#/' | sed "s/^X/rm -rf $VERBOSE /" > $RM_SCRIPT

    if [ $DRY_RUN -ne 1 ]; then
        sudo sh -x $RM_SCRIPT
    else
        grep '^rm' $RM_SCRIPT
    fi

    rm -f $RM_SCRIPT
done
