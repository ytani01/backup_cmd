#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`

DISKS="sdb sdc sdd sde sdf"
MAIL_TO="yoichi@tanibayashi.jp"
MAIL_SUBJECT="$MYNAME"

CHECK_SMART=/conf/etc/backupcmd/check-smart.sh
CHECK_SMART_OPT=
TEMP_FILE=`mktemp`
DRY_RUN=

### functions
usage() {
    echo
    echo "    usage: ${MYNAME} [-n]"
    echo
}

### main
while getopts nt OPT; do
    case $OPT in
        n) DRY_RUN=true;;
        t) CHECK_SMART_OPT="-t";;
        *) usage
           exit 1
           ;;
    esac
done
shift `expr $OPTIND - 1`


echo > $TEMP_FILE
for d in $DISKS; do
    echo $d
    $CHECK_SMART $CHECK_SMART_OPT $d >> $TEMP_FILE
    echo >> $TEMP_FILE
done

cat $TEMP_FILE
if [ -z "$DRY_RUN" ]; then
    cat $TEMP_FILE | mail -s $MAIL_SUBJECT $MAIL_TO
fi    

rm -fv $TEMP_FILE
