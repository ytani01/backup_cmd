#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
DSTDIR=/conf/etc

FILES="backup_inc.sh backup_dirs.sh"

for f in ${FILES}; do
    sudo cp -v $f ${DSTDIR}
done
