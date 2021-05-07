#!/bin/ksh -x
#               DO NOT CHANGE THE NAME OF SHELL
################################################################
# Author    :   Barbara Battistelli - Comitsiel
# Goal      :   Ricompila i .pc e i .inp e i .inp
################################################################

#***************************************************************
# variabili
#***************************************************************
. /u/dsim/.profile
CM45_DIR=/u/dsim/CM45_DIR
SCRIPT_DIR=${CM45_DIR}/SCRIPT
LOG_DIR=${CM45_DIR}/LOG
LISTA_DIR=${CM45_DIR}/LISTE

INST_PATCH_LOG=${LOG_DIR}/instpatch.log
CONFIG_FILE=${SCRIPT_DIR}/Config_file

ricompila_log_name=`grep RICOMPILA_LOG $CONFIG_FILE | awk '{ print $2 }'`
RICOMPILA_LOG=${LOG_DIR}/${ricompila_log_name}

pgmincl_out_name=`grep PGMINCL_OUT $CONFIG_FILE | awk '{ print $2 }'`
PGMINCL_OUT=${LISTA_DIR}/${pgmincl_out_name}

check_frm_out_name=`grep CHECK_FRM_OUT $CONFIG_FILE | awk '{ print $2 }'`
CHECK_FRM_OUT=${LISTA_DIR}/${check_frm_out_name}

check_bin_out_name=`grep CHECK_BIN_OUT $CONFIG_FILE | awk '{ print $2 }'`
CHECK_BIN_OUT=${LISTA_DIR}/${check_bin_out_name}

comodo0_name=ricompila.comodo0
COMODO0=${LOG_DIR}/${comodo0_name}

comodo_name=ricompila.comodo
COMODO=${LOG_DIR}/${comodo_name}

TODAY=`date "+[%d-%b-%y %H:%M:%S]"`

if [[ $pgmincl_out_name = "" || $check_frm_out_name  = "" || $check_bin_out_name = "" ]]
then
  echo "$TODAY $0 : PGMINCL_OUT o CHECK_FRM_OUT o CHECK_BIN_OUT con valore NULL --> controlla $CONFIG_FILE (exit 1)">>$INST_PATCH_LOG
  exit 1
fi

rm $RICOMPILA_LOG 2>/dev/null
rm $COMODO0 2>/dev/null
rm $COMODO 2>/dev/null

echo "$TODAY $0 : START" >>$INST_PATCH_LOG

#***************************************************************
# Metto i pc da ricompilare in un file di appoggio
#***************************************************************
cat $PGMINCL_OUT > $COMODO0 2>/dev/null
cat $CHECK_BIN_OUT >> $COMODO0 2>/dev/null
sort -u $COMODO0 > $COMODO

#***************************************************************
# Ricompilo i pc (prima li rimuovo)
#***************************************************************
if [[ -s $COMODO ]]
then
  for f in `cat $COMODO`
  do
    echo "************** Remove & Compile $f **************" >> $RICOMPILA_LOG
    rm /u/dsim/bin/$f >> $RICOMPILA_LOG 2>&1
    echo "" >> $RICOMPILA_LOG
    siso p1 $f.pc >> $RICOMPILA_LOG 2>&1
  done
fi

#***************************************************************
# Ricompilo gli imp
#***************************************************************
if [[ -s $CHECK_FRM_OUT ]]
then
  for f in `cat $CHECK_FRM_OUT`
  do
#FORM=`echo $f | tr [a-z] [A-Z] |sed 's/\.FRM/\.inp/g' | tr [a-z] [A-Z]`
    echo "**************  Compile $f **************" >> $RICOMPILA_LOG
    siso f1 $f.inp >> $RICOMPILA_LOG 2>&1
    echo "" >> $RICOMPILA_LOG
  done
fi

rm $COMODO 2>/dev/null
rm $COMODO0 2>/dev/null
echo "$TODAY $0 : END --> $ricompila_log_name (exit 0)">>$INST_PATCH_LOG

exit 0
