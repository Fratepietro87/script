#!/bin/ksh -x
#          DO NOT CHANGE THE NAME OF SHELL
#################################################################
# Author: Barbara Battistelli - Comitsiel
# Goal	: Lancia pr_obj (ricompilazione massiva package) in remoto
#################################################################

#***************************************************************
# Variabili
#***************************************************************
. /u/dsim/.profile
CM45_DIR=/u/dsim/CM45_DIR
SCRIPT_DIR=${CM45_DIR}/SCRIPT
LOG_DIR=${CM45_DIR}/LOG
LISTA_DIR=${CM45_DIR}/LISTE
SQL_DIR=/u/dsim/sql

INST_PATCH_LOG=${LOG_DIR}/instpatch.log
CONFIG_FILE=${SCRIPT_DIR}/Config_file
FILE_PROBJ=${SCRIPT_DIR}/EseguiPrObj.sql

VER=`grep VER $CONFIG_FILE | awk '{ print $2 }'`
TODAY=`date "+[%d-%b-%y %H:%M:%S]"`

ISTANZA=`grep ISTANZA $CONFIG_FILE | awk '{ print $2 }'`
USER_PW=`grep USER_PW $CONFIG_FILE | awk '{ print $2 }'`

echo "$TODAY $0 : START">>$INST_PATCH_LOG
if [[ $ISTANZA = "" || $USER_PW = "" ]]
then
  echo "$TODAY $0 : ISTANZA o USER_PW con valore NULL --> controlla $CONFIG_FILE (exit 1)">>$INST_PATCH_LOG
  exit 1
fi

# carico .profile e lancio sqlplus 
#-------------------------------------

cd $SCRIPT_DIR
$ORACLE_HOME/bin/sqlplus $USER_PW@$ISTANZA @$FILE_PROBJ > $LOG_DIR/probj.log


echo "$TODAY $0 : END (exit 0)">>$INST_PATCH_LOG
exit 0
