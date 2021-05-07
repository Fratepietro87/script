#!/bin/csh

# ***************************************************************************************
# 				MountWEB_script
# 
# Esegue il mount della directory remota dalla quale copiare la consegna da inserire
# in ContInuus, i path utilizzati sono presenti nel file WebPath.ini
# Eventuali errori vengono stampati nel file ErrMsg
#
# Input:	$1 Progetto
#		$2 comitver
#
#
# Autore Luciano Giovannini Nov. 2000
# ***************************************************************************************

set PROGETTO = $1
set COMITVER = $2
set REMOTE_HP_MIG_DIR = "/LocalCons/LOCAL_WEB"
set MIG_LOCAL_ROOT = "/usr/CONT_SRV/LOCAL_WEB"
set REMOTE_MIG_ROOT = "/Consegne_WEB"
set CCM45_DB = "/usr/CONT_SRV/ccmdb/DB_WEB"
set CCM45_DBlog = "${CCM45_DB}/lib/notify/log"
set SCRIPT_DIR = "${CCM45_DB}/lib/notify/Unix"
set COMMON_DIR = "${SCRIPT_DIR}/COMMON"
set WebPath_ini = "${COMMON_DIR}/WebPath.ini"
set WebPathMig = `cat ${WebPath_ini}|awk -F"${PROGETTO}:" '{ print $2}'`
set res = 0
#set res = `remsh linux_cm -l root -n "smbumount /Consegne_WEB;" echo '$?'`

if (-d ${MIG_LOCAL_ROOT}/${PROGETTO}${COMITVER} ) then
  rm -rf ${MIG_LOCAL_ROOT}/${PROGETTO}${COMITVER}
endif

# ***************************************************************************************
# mount della directory dell'utente che effettua la Migrazione in Continuus 
# ***************************************************************************************

set res = `remsh linux_cm -l root -n "smbmount ${WebPathMig} ${REMOTE_MIG_ROOT} -U guest%;" echo '$?'`

if( "$res" != 0 ) then
  echo "Error ${WebPathMig} not mounted" >>&/$CCM45_DBlog/ErrMsg
  exit 4
endif

# ***************************************************************************************
# Copia della Consegna su c-gpm2-c
# ***************************************************************************************

set res = `remsh linux_cm -l root -n "cp -r ${REMOTE_MIG_ROOT}/${PROGETTO}${COMITVER} ${REMOTE_HP_MIG_DIR};" echo '$?'`
echo $res

if( "$res" != 0 ) then
  echo "Consegna ${PROGETTO}${COMITVER} non copiata" >>&/$CCM45_DBlog/ErrMsg
  set res = `remsh linux_cm -l root -n "smbumount ${REMOTE_MIG_ROOT};" echo '$?'`
  exit 8
endif

# ***************************************************************************************
#  Tutto Ok : umount della directory remota
# ***************************************************************************************

set res = `remsh linux_cm -l root -n "smbumount ${REMOTE_MIG_ROOT};" echo '$?'`

exit 0
