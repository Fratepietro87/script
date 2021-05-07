#!/bin/ksh -x
#          DO NOT CHANGE THE NAME OF SHELL
################################################################
# Author: Barbara Battistelli - Comitsiel
# Goal	: prende in input il FILE sisobd.she e
#	  crea le liste per fare il tar da portare in produzione
################################################################

#***************************************************************
# Variabili
#***************************************************************
. /u/dsim/.profile
CM45_DIR=/u/dsim/CM45_DIR
SISO_DIR=/u/dsim/siso
SCRIPT_DIR=${CM45_DIR}/SCRIPT
LOG_DIR=${CM45_DIR}/LOG
LISTA_DIR=${CM45_DIR}/LISTE
DELTA_PATCH_SQL=$1


INST_PATCH_LOG=${LOG_DIR}/instpatch.log
CONFIG_FILE=${SCRIPT_DIR}/Config_file

file_sisobd_she_name=`grep FILE_SISOBD_SHE $CONFIG_FILE | awk '{ print $2 }'`
FILE_SISOBD_SHE=${SISO_DIR}/${file_sisobd_she_name}

upd_lista_name=`grep UPD_LISTA $CONFIG_FILE | awk '{ print $2 }'`
UPD_LISTA=${LISTA_DIR}/${upd_lista_name}

upd_iface_lista_name=`grep UPD_IFACE_LISTA $CONFIG_FILE | awk '{ print $2 }'`
UPD_IFACE_LISTA=${LISTA_DIR}/${upd_iface_lista_name}

upd_iface_ch_lista_name=`grep UPD_IFACE_CH_LISTA $CONFIG_FILE | awk '{ print $2 }'`
UPD_IFACE_CH_LISTA=${LISTA_DIR}/${upd_iface_ch_lista_name}

pgmincl_out_name=`grep PGMINCL_OUT $CONFIG_FILE | awk '{ print $2 }'`
PGMINCL_OUT=${LISTA_DIR}/${pgmincl_out_name}

comodo_name=crea_lista.comodo
COMODO=${LOG_DIR}/${comodo_name}

DATA=`grep DATA $CONFIG_FILE | awk '{ print $2 }'`
TODAY=`date "+[%d-%b-%y %H:%M:%S]"`

PATCH_SQL=`grep PATCH_SQL $CONFIG_FILE | awk '{ print $2 }'`

echo "$TODAY $0 : START">>$INST_PATCH_LOG

if [[ $file_sisobd_she_name = "" || ! -s $FILE_SISOBD_SHE ]]
then
  echo "$TODAY $0 : Var FILE_SISOBD_SHE vuota in $CONFIG_FILE o file inesistente(exit 1)">>$INST_PATCH_LOG
  exit 1
fi

rm -f $COMODO 2>/dev/null
rm -f $UPD_LISTA 2>/dev/null
#rm $UPD_IFACE_LISTA 2>/dev/null
#rm $UPD_IFACE_CH_LISTA 2>/dev/null

#***************************************************************
# Ripulisco sisobd
#***************************************************************
if [[ "`grep init_neg $FILE_SISOBD_SHE`" = "" ]]
then
  cat $FILE_SISOBD_SHE |grep -vE "siso|R|H|S|C|pozzo|_DIP|.rep|.rpt"|awk '{ print $3}'>$COMODO
  #cat $FILE_SISOBD_SHE | grep -vE "siso|R|H|pozzo" | sed -e 's/compatch //' \
  #-e 's/# 0//' -e 's/# 1//' -e 's/# 2//' -e 's/# 3//' -e 's/# 4//' \
  #-e 's/# 5//' -e 's/# 6//' -e 's/P //' -e 's/F //' -e 's/Q //'  > $COMODO
else
  cat $FILE_SISOBD_SHE |grep -vE "siso|R|H|S|C|_DIP|.rep|.rpt"|awk '{ print $3}'>$COMODO
  #cat $FILE_SISOBD_SHE | grep -vE "siso|R|H" | sed -e 's/compatch //' \
  #-e 's/# 0//' -e 's/# 1//' -e 's/# 2//' -e 's/# 3//' -e 's/# 4//' \
  #-e 's/# 5//' -e 's/# 6//' -e 's/P //' -e 's/F //' -e 's/Q //'  > $COMODO
fi


#***************************************************************
# Trovo gli sql
#***************************************************************
SQL=`cat $COMODO | grep -E ".sql|.plb"`
for f in `echo $SQL`
do
  echo ./sql/$f >> $UPD_LISTA
done

# Aggiungo stoproc.sql e il delta_patch
#***************************************************************
echo ./sql/stoproc.sql >> $UPD_LISTA
if [[ "$PATCH_SQL" != "" ]]
then 
	echo ./sql/$PATCH_SQL >> $UPD_LISTA
fi

#***************************************************************
# Trovo i form
#***************************************************************
FRM=`cat $COMODO | grep '\.inp' | sed 's/\.inp//g' | tr a-z A-Z`
for f in `echo $FRM`
do
  echo ./frm/$f.frm >> $UPD_LISTA
done

#***************************************************************
# Trovo i pc
#***************************************************************
BIN=`cat $COMODO | grep '\.pc' | sed 's/\.pc//'`
for f in `echo $BIN`
do
  echo ./bin/$f >> $UPD_LISTA
done

#***************************************************************
# Aggiungo i pc che devono essere ricompilati
#***************************************************************
if [[ $pgmincl_out_name != "" && -s $PGMINCL_OUT ]]
then
  echo "$TODAY $0 : Aggiungo i file presenti in $pgmincl_out_name" >>$INST_PATCH_LOG
  for f in `cat $PGMINCL_OUT`
  do
    echo ./bin/$f >> $UPD_LISTA
  done
else
  echo "$TODAY $0 : Var PGMINCL_OUT non configurata in $CONFIG_FILE o file inesistente (exit 1)">>$INST_PATCH_LOG
  exit 1
fi


#***************************************************************
# Cancello i file di appoggio
#***************************************************************
rm -f $COMODO 2>/dev/null

echo "$TODAY $0 : END -> $upd_lista_name, $upd_iface_lista_name, $upd_iface_ch_lista_name (exit 0)">>$INST_PATCH_LOG

exit 0
