#!/bin/sh
#
# (c) 2024 Yoichi Tanibayashi
#
DSTDIR=/conf/etc/backupcmd

FILES="backup_all.sh.sample backup_inc.sh backup_dirs.sh backup_mon.sh backup_src.txt.sample backup_clean_incomplete.sh dump-root.sh check-smart.sh clean-backup.sh"

if [ ! -d $DSTDIR ]; then
    sudo mkdir -pv $DSTDIR
fi

for f in ${FILES}; do
    sudo cp -fv $f ${DSTDIR}
done
