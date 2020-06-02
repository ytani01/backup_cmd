#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
DSTDIR=/conf/etc

FILES="backup_inc.sh backup_dirs.sh backup_src.txt.sample clean-incomplete-dirs.sh"

for f in ${FILES}; do
    sudo cp -fv $f ${DSTDIR}
done
