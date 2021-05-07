#!/bin/ksh -x
#          DO NOT CHANGE THE NAME OF SHELL
#################################################################
# Author: Barbara Battistelli - Comitsiel
# Goal	: Lancia patchxxxxx.sql in remoto 
#		  Il nome del file patch viene passato  come parametro
#################################################################

#***************************************************************
# Variabili
#***************************************************************
. /u/dsim/.profile
CM45_DIR=/u/dsim/CM45_DIR
SCRIPT_DIR=${CM45_DIR}/SCRIPT
LOG_DIR=${CM45_DIR}/LOG
LISTA_DIR=${CM45_DIR}/LISTE
SISO_DIR=/u/dsim/siso
SQL_DIR=/u/dsim/sql

INST_PATCH_LOG=${LOG_DIR}/instpatch.log
CONFIG_FILE=${SCRIPT_DIR}/Config_file

file_patch_name=$1
FILE_PATCH=${SQL_DIR}/${file_patch_name}

VER=`grep VER $CONFIG_FILE | awk '{ print $2 }'`
TODAY=`date "+[%d-%b-%y %H:%M:%S]"`

ISTANZA=`grep ISTANZA $CONFIG_FILE | awk '{ print $2 }'`
USER_PW=`grep USER_PW $CONFIG_FILE | awk '{ print $2 }'`

echo "$TODAY $0 : START">>$INST_PATCH_LOG
if [[ ! -s $FILE_PATCH || $ISTANZA = "" || $USER_PW = "" ]]
then
  echo "$TODAY $0 : FILE_STOPROC o ISTANZA o USER_PW con valore NULL --> controlla $CONFIG_FILE (exit 1)">>$INST_PATCH_LOG
  exit 1
fi

# carico .profile e lancio patch 
#-------------------------------------
echo "exit" >> $FILE_PATCH
cd $SQL_DIR
$ORACLE_HOME/bin/sqlplus $USER_PW@$ISTANZA @$FILE_PATCH > $LOG_DIR/patch.log

echo "$TODAY $0 : END (exit 0)">>$INST_PATCH_LOG
exit 0
