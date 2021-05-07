#!/bin/ksh -x
#          DO NOT CHANGE THE NAME OF SHELL
#################################################################
# Author: Barbara Battistelli - Comitsiel
# Goal	: trova i .pc che devono essere ricompilati perche'
#	  utilizzano le routine presenti nella patch
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

INST_PATCH_LOG=${LOG_DIR}/instpatch.log
CONFIG_FILE=${SCRIPT_DIR}/Config_file

file_sisobd_she_name=`grep FILE_SISOBD_SHE $CONFIG_FILE | awk '{ print $2 }'`
FILE_SISOBD_SHE=${SISO_DIR}/${file_sisobd_she_name}

pgmincl_out_name=`grep PGMINCL_OUT $CONFIG_FILE | awk '{ print $2 }'`
PGMINCL_OUT=${LISTA_DIR}/${pgmincl_out_name}

file_interface=`grep FILE_INTERFACE $CONFIG_FILE | awk '{ print $2 }'`
FILE_INTERFACE=${LISTA_DIR}/${file_interface}

file_interface_comp=`grep FILE_INTF_COMP $CONFIG_FILE | awk '{ print $2 }'`
FILE_INTERFACE_COMP=${LISTA_DIR}/${file_interface_comp}      

comodo_name=pgmincl_comodo
COMODO=${LOG_DIR}/${comodo_name}

VER=`grep VER $CONFIG_FILE | awk '{ print $2 }'`
TODAY=`date "+[%d-%b-%y %H:%M:%S]"`

rm -f $PGMINCL_OUT 
rm -f $COMODO 
rm -f $FILE_INTERFACE_COMP 

#b=""
#until [[ $b =  "y"  ]]
#do
#read b?"continuo?"
#done

echo "$TODAY $0 : START">>$INST_PATCH_LOG
if [[ ! -s $FILE_SISOBD_SHE ]]
then
  echo "$TODAY $0 : FILE_SISOBD_SHE con valore NULL --> controlla $CONFIG_FILE (exit 1)">>$INST_PATCH_LOG
  exit 1
fi

#***************************************************************
# Estrapolo la lista delle routine e degli header da sisobd
#***************************************************************

for r in `cat $FILE_SISOBD_SHE | grep -vE "siso|_DIP"| grep -E "R|H" | awk '{ print $3 }'`
do
LISTA_ROUTINE="$LISTA_ROUTINE|$r"
done
LISTA_ROUTINE=`echo $LISTA_ROUTINE | sed '1,$s/\|//'`

if [[ $VER = "" || $LISTA_ROUTINE = "" ]]
then
  echo "$TODAY $0 : VER o LISTA_ROUTINE con valore NULL --> controlla $CONFIG_FILE (exit 1)">>$INST_PATCH_LOG
  exit 1
fi

for f in `ls $BIN`
do
  ESITO=`what $BIN/$f | grep -E $LISTA_ROUTINE`
  if [[ $ESITO != "" ]]
  then
    echo $f | grep -v "\." >> $COMODO
  fi
done

#b=""
#until [[ $b =  "y"  ]]
#do
#read b?"continuo?"
#done

#***************************************************************
# Tolgo le interfacce e le metto in un altro file
#***************************************************************

for f in `cat $FILE_INTERFACE`
do
	LISTA_INTERFACE="$LISTA_INTERFACE|$f"
done

LISTA_INTERFACE=`echo $LISTA_INTERFACE | sed '1,$s/\|//'`
cat $COMODO | grep -vE $LISTA_INTERFACE |sort -u > $PGMINCL_OUT

#b=""
#until [[ $b =  "y"  ]]
#do
#read b?"continuo?"
#done

diff -wb $COMODO $PGMINCL_OUT | grep "<" | awk '{ print $2}' |sort -u > $FILE_INTERFACE_COMP

rm $COMODO 2>/dev/null
echo "$TODAY $0 : END --> $pgmincl_out_name (exit 0)">>$INST_PATCH_LOG
exit 0
