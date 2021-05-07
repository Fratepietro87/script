#!/bin/ksh -x
#          DO NOT CHANGE THE NAME OF SHELL
#################################################################
# Author: Barbara Battistelli - Comitsiel
# Goal	: Lancia init_neg in remoto
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
FILE_INITNEG=${SQL_DIR}/init_neg.sql
FILE_INITNEG_LIS=${SQL_DIR}/init_neg.lis
FILE_INITNEG_TEMP=${SQL_DIR}/init_neg.temp

#file_stoproc_name=`grep FILE_STOPROC $CONFIG_FILE | awk '{ print $2 }'`
#FILE_STOPROC=${SQL_DIR}/${file_stoproc_name}

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

# inserisco spool 
#-------------------------------------
echo "spool $FILE_INITNEG_LIS" > $FILE_INITNEG_TEMP 
cat $FILE_INITNEG  >> $FILE_INITNEG_TEMP 
echo "spool off" >>  $FILE_INITNEG_TEMP
echo "exit" >>  $FILE_INITNEG_TEMP
mv $FILE_INITNEG_TEMP $FILE_INITNEG 

# carico .profile e lancio sqlplus 
#-------------------------------------

cd $SQL_DIR
$ORACLE_HOME/bin/sqlplus $USER_PW@$ISTANZA @$FILE_INITNEG > $LOG_DIR/init_neg.log

# lancio sisoins l 
#-------------------------------------
cd $SISO_DIR
./sisoins l > $LOG_DIR/sisoins.log


echo "$TODAY $0 : END (exit 0)">>$INST_PATCH_LOG
exit 0
