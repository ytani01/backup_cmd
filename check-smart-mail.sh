#!/bin/sh
#
MYNAME=`basename $0`

MAILTO="yoichi@tanibayashi.jp"
DISKS="sdb sdc sdd sde sdf"

MAILSUBJECT="$MYNAME"

CHECK_SMART=/conf/etc/check-smart.sh

TEMP_FILE=`mktemp`

echo > $TEMP_FILE

for d in $DISKS; do
    $CHECK_SMART $d >> $TEMP_FILE
    echo >> $TEMP_FILE
done

cat $TEMP_FILE | mail -s $MAILSUBJECT $MAILTO
