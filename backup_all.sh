#!/bin/sh
#
MYNAME=`basename $0`

SRCS="root home usr misc data-utf8 data"

BASEDIR="/conf/etc"
BACKUP_CMD="${BASEDIR}/backup_dirs.sh"
BACKUP_OPT=""
BACKUP_DST="backup:/tank1/backups/fs"

usage () {
    echo
    echo "    usage: ${MYNAME} [-n] [-j jobs]"
    echo
}

tsecho () {
    _DATESTR=`LANG=C date +'%Y/%m%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${MYNAME}> $*"
}

tseval() {
    _CMDLINE=$*
    tsecho eval "$_CMDLINE"
    eval "$_CMDLINE"
    _RET=$?
    if [ $_RET -ne 0 ]; then
        tsecho "error($_RET)"
        exit $_RET
    fi
    return $_RET
}

while getopts j:n OPT; do
    case $OPT in
        j) if [ $OPTARG -ge 1 ]; then
               BACKUP_OPT="${BACKUP_OPT} -j ${OPTARG}"
           else
               usage
               exit 1
           fi
           ;;
        n) BACKUP_OPT="${BACKUP_OPT} -n" ;;
        *) usage
           exit 1
           ;;
    esac
done
shift `expr $OPTIND - 1`

for s in $SRCS; do
    tsecho "src=${s}"
    tseval ${BACKUP_CMD} ${BACKUP_OPT} -f ${BASEDIR}/backup_src-${s}.txt ${BACKUP_DST}/${s}
    tsecho "src=${s}: done.  =========="
    echo ""
done

tsecho "done"
exit 0
