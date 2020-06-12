#!/bin/sh
#
MYNAME=`basename $0`

SRCS="root home usr misc data-utf8 data"

BASEDIR="/conf/etc"
BACKUP_CMD="${BASEDIR}/backup_dirs.sh"
BACKUP_DST="backup:/tank1/backups/fs"

tsecho () {
    _DATESTR=`LANG=C date +'%Y/%m%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

RET=0
for s in $SRCS; do
    tsecho "src=${s}"
    
    CMDLINE="${BACKUP_CMD} -f ${BASEDIR}/backup_src-${s}.txt ${BACKUP_DST}/${s}"
    tsecho $CMDLINE
    eval $CMDLINE
    RET=$?
    if [ ${RET} -ne 0 ]; then
        break
    fi
    
    tsecho "src=${s}: done.  =========="
    echo ""
done

tsecho "done(${RET})"
exit ${RET}
