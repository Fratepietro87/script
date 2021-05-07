#!/bin/ksh -x
# 				DO NOT CHANGE THE NAME OF SHELL
############################################################################
# Author: Barbara Battistelli Comitsiel
# Modified: Luca Brizzolara - Selesta
# Goal	: Controlla le date dei file sotto /u/dsim/bin e /u/dsim/frm
############################################################################

# Variabili
#----------------------------------------------------------
. /u/dsim/.profile
CM45_DIR=/u/dsim/CM45_DIR
LOG_DIR=${CM45_DIR}/LOG
SCRIPT_DIR=${CM45_DIR}/SCRIPT
LISTA_DIR=${CM45_DIR}/LISTE
INST_PATCH_LOG=${LOG_DIR}/instpatch.log
CONFIG_FILE=${SCRIPT_DIR}/Config_file


check_frm_out_name=`grep CHECK_FRM_OUT $CONFIG_FILE | awk '{ print $2 }'`
CHECK_FRM_OUT=${LISTA_DIR}/${check_frm_out_name}

check_bin_out_name=`grep CHECK_BIN_OUT $CONFIG_FILE | awk '{ print $2 }'`
CHECK_BIN_OUT=${LISTA_DIR}/${check_bin_out_name}

upd_lista_name=`grep UPD_LISTA $CONFIG_FILE | awk '{ print $2 }'`
UPD_LISTA=${LISTA_DIR}/${upd_lista_name}

DATA=`grep DATA $CONFIG_FILE | awk '{ print $2 }'`
DEBUG=n
TODAY=`date "+[%d-%b-%y %H:%M:%S]"`


echo "$TODAY $0 : START">>$INST_PATCH_LOG

if [[ ! -s $UPD_LISTA || $DATA = "" ]]
then
  echo "$TODAY $0 : UPD_LISTA o DATA con valore NULL --> controlla $CONFIG_FILE (exit 1)">>$INST_PATCH_LOG
  exit 1
fi

# Una lista per i pc ed una per i form
#-------------------------------------
rm -f $CHECK_FRM_OUT 2>/dev/null
rm -f $CHECK_BIN_OUT 2>/dev/null

fine_mese()
{
#----------------------------------------------------#
# Calcola l'ultimo giorno del mese
# In:
#     MM        Mese elaborazione
# Out:
#     ULTIMO_GG   Ultimo gg del mese
#----------------------------------------------------#

if [[ "$DEBUG" = "y" ]]; then set -x; fi

case $MM in
  01|03|05|07|08|10|12) ULTIMO_GG=31;;
  04|06|09|11) ULTIMO_GG=30;;
  * )
    CALE=`cal $MM $ANNO`

    for ULTIMO_GG in `echo $CALE`
    do
      echo >/dev/null 2>&1
    done
    ;;
esac
echo $ULTIMO_GG
}


# Estrapolo giorno, mese e anno dalla data
#-----------------------------------------
DAY=`echo $DATA | awk -F"-" '{ print $1 }'`
MESE=`echo $DATA | awk -F"-" '{ print $2 }'`
ANNO=`echo $DATA | awk -F"-" '{ print $3 }'`

case $MESE in
	"Jan") MM=01;;
	"Feb") MM=02;;
	"Mar") MM=03;;
	"Apr") MM=04;;
	"May") MM=05;;
	"Jun") MM=06;;
	"Jul") MM=07;;
	"Aug") MM=08;;
	"Sep") MM=09;;
	"Oct") MM=10;;
	"Nov") MM=11;;
	"Dec") MM=12;;
	* ) exit 1;;
esac 

if [[ "$ANNO" = "" || "$DAY" = "" || $DAY -le 0 || $DAY -gt `fine_mese` ]]
then
  exit 1
fi

#******************************************************************
# Se il file non esiste o e' vecchio deve essere ricompilato 
#******************************************************************
for f in `cat $UPD_LISTA | grep -E "bin|frm"| sed 's/\.\//\//'` 
do
# E' UN PC
  if [[ "`echo /u/dsim$f | grep "/u/dsim/bin"`" != "" ]]
  then
    if [[ -a /u/dsim$f ]]
    then
# ESISTE
      MM=`ls -l /u/dsim$f |awk '{print $6}' 2>/dev/null`
      DD=`ls -l /u/dsim$f |awk '{print $7}' 2>/dev/null`
      if [[ "$MESE" != "$MM"  || $DD -lt $DAY ]]
# E' VECCHIO
      then
        echo "/u/dsim$f" | awk -F"/" '{ print $5 }' >> $CHECK_BIN_OUT
      fi
# NON ESISTE
    else
      echo "/u/dsim$f" | awk -F"/" '{ print $5 }' >> $CHECK_BIN_OUT
    fi
# E' UN FRM
  else
    if [[ -a /u/dsim$f ]]
    then 
# ESISTE
      MM=`ls -l /u/dsim$f |awk '{print $6}' 2>/dev/null`
      DD=`ls -l /u/dsim$f |awk '{print $7}' 2>/dev/null`
      if [[ "$MESE" != "$MM"  || $DD -lt $DAY ]]
# E' VECCHIO
      then
	echo "/u/dsim$f" | sed 's/\.frm//g' | tr [A-Z] [a-z] | awk -F"/" '{ print $5 }' >> $CHECK_FRM_OUT
      fi
# NON ESISTE
    else
      echo "/u/dsim$f" | sed 's/\.frm//g' | tr [A-Z] [a-z] | awk -F"/" '{ print $5 }' >> $CHECK_FRM_OUT
    fi
  fi
done

echo "$TODAY $0 : END --> $check_frm_out_name, $check_bin_out_name (exit 0)">>$INST_PATCH_LOG

exit 0
