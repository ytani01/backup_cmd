#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
DSTDIR=/conf/etc

FILES="backup_all-sample.sh backup_inc.sh backup_dirs.sh backup_mon.sh backup_src.txt.sample backup_clean_incomplete.sh"

for f in ${FILES}; do
    sudo cp -fv $f ${DSTDIR}
done
