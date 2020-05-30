#!/bin/sh
#
# $Id: backup-dirs.sh,v 1.6 2020/04/16 14:42:33 root Exp root $
#
#####
LANG=ja_JP.UTF-8

RSYNC_CMD="/usr/local/bin/rsync"
#RSYNC_OPT="-avS --delete"
RSYNC_OPT="-avzS --delete"
RSYNC_OUT_FILTER="grep -v '^sending incremental' | grep -v '^sent.*bytes' | grep -v '^total size is' | grep -v '^ *$'"

BACKUP_DIR0="/common/backup0"
BACKUP_DIR1="/common/backup1"
LINK_DEST="../backup0"

SRC_DIRS1=`ls -lF /common/ | grep -v backup | grep -v nas | grep @ | sed 's/^.*@ .. //' | grep '^\/\.[0-9]'`
SRC_DIRS2=`ls -lF /private/ | grep -v backup | grep -v nas | grep @ | sed 's/^.*@ .. //' | grep '^\/\.[0-9]'`

SRC_DIRS="/root /etc /conf /var /usr/local/www \
    ${SRC_DIRS1} ${SRC_DIRS2}"

###
### backup_dir1
###
backup_dir1 () {
    echo ">>backup_dir1:$*"

    dir1=$1
    backup_dir1=$2

    if [ ! -d ${dir1} ]; then
	echo "### ${dir1}: no such directory"
	return
    fi

    if [ ! -d ${backup_dir1} ]; then
	echo "### backup directory ${backup_dir1}: no such directory"
	return
    fi

    src_dir=`dirname ${dir1}`
    src_obj=`basename ${dir1}`
    dst_dir=`echo ${backup_dir1}${src_dir} | sed 's?/\.[0-9]?/_N?'`

    echo "\$dst_dir=${dst_dir}"
    mkdir -p ${dst_dir}

    cd ${src_dir}
    #cmdline="${RSYNC_CMD} ${RSYNC_OPT} ${src_obj} ${dst_dir} | ${RSYNC_OUT_FILTER}"
    cmdline="${RSYNC_CMD} ${RSYNC_OPT} ${src_obj} ${dst_dir}"

    date +'%Y-%m-%d %H:%M:%S'
    echo "[`pwd`]# ${cmdline}"
    eval ${cmdline}
    date +'%Y-%m-%d %H:%M:%S'

    echo "<<backup_dir1:$*"
    echo
    return
}

###
### main
###

#
# BACKUP_DIR0 -> BACKUP_DIR1
#

#BACKUP1_CMDNAME="backup0-1.sh"
#L_BACKUP1_CMD="/common/myhost/bin/${BACKUP1_CMDNAME}"
#R_BACKUP1_CMD="/mnt/DroboFS/Shares/Public/fs/bin/${BACKUP1_CMDNAME}"
#
#if [ -x ${L_BACKUP1_CMD} ]; then
#    chown root:yt ${L_BACKUP1_CMD}
#    chmod u+s ${L_BACKUP1_CMD}
#    ls -l ${L_BACKUP1_CMD}
#
#    sudo -u ytani ssh nas ${R_BACKUP1_CMD}
#else
#    echo "${L_BACKUP1_CMD}: not found"
#fi

# for auto-mount
ls ${BACKUP_DIR0}/ ${BACK_DIR1}/ > /dev/null

if [ -d ${BACKUP_DIR0} -a -d ${BACKUP_DIR1} ]; then
    cd ${BACKUP_DIR1}
    ls > /dev/null
    cd ${BACKUP_DIR0}
    ls > /dev/null

    #cmdline="${RSYNC_CMD} ${RSYNC_OPT} `echo *` ${BACKUP_DIR1} | ${RSYNC_OUT_FILTER}"
    cmdline="${RSYNC_CMD} ${RSYNC_OPT} `echo *` ${BACKUP_DIR1}"
#    if [ -d ${LINK_DEST} ]; then
#        cmdline="${RSYNC_CMD} ${RSYNC_OPT} --link-dest=${LINK_DEST} `echo *` ${BACKUP_DIR1}"
#    else
#        cmdline="${RSYNC_CMD} ${RSYNC_OPT} `echo *` ${BACKUP_DIR1}"
#    fi

    date +'%Y-%m-%d %H:%M:%S'
    echo "[`pwd`]# ${cmdline}"
    eval ${cmdline}
    date +'%Y-%m-%d %H:%M:%S'
fi

#
# backup
#
date +"start %Y-%m-%d(%a) %H:%M:%S" > ${BACKUP_DIR0}/timestamp.txt

for dir in ${SRC_DIRS}; do
    echo
    echo "===== ${dir}"

    BACKUP_DIR=${BACKUP_DIR0}
    if ( echo ${dir} | grep '@' > /dev/null ) ; then
	BACKUP_DIR=`echo ${dir} | sed 's/^.*\@//'`
	dir=`echo ${dir} | sed 's/\@.*$//'`

	echo "> ${dir}: \$BACKUP_DIR=${BACKUP_DIR}"
    fi

    backup_dir1 ${dir} ${BACKUP_DIR}
done

date +"end   %Y-%m-%d(%a) %H:%M:%S" >> ${BACKUP_DIR0}/timestamp.txt
cat ${BACKUP_DIR0}/timestamp.txt

echo "===== END ====="
exit 0
