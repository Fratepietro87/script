#!/bin/ksh -x
#########################################################################
#  Name  : TPatch.ksh
#  Author: Barbara Battistelli - Comitsiel spa
#  Date  : 6 Luglio 1999
#  Goal  : Esegue il parsing di sisobd.she per caricare in oracle
#          l'elenco dei sorgenti con tipo, versione e data
#          Genera un sql per cancellare i sorgenti obsoleti dalla
#          tabella TPacth prima di caricarli con sqlldr
#########################################################################

#************************************************************************
# Variabili
#************************************************************************
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

tp_ctl_name=`grep TP_CTL $CONFIG_FILE | awk '{ print $2 }'`
TP_CTL=${LISTA_DIR}/${tp_ctl_name}

tp_log_name=`grep TP_LOG $CONFIG_FILE | awk '{ print $2 }'`
TP_LOG=${LOG_DIR}/${tp_log_name}

tp_sql_name=`grep TP_SQL $CONFIG_FILE | awk '{ print $2 }'`
TP_SQL=${LISTA_DIR}/${tp_sql_name}

tp_lis_name=`grep TP_LIS $CONFIG_FILE | awk '{ print $2 }'`
TP_LIS=${LISTA_DIR}/${tp_lis_name}

tp_ldr_log=`grep TP_LDR_LOG $CONFIG_FILE | awk '{ print $2 }'`
TP_LDR_LOG=${LOG_DIR}/${tp_ldr_log}

comodo_name=tpatch.comodo
COMODO=${LOG_DIR}/${comodo_name}

TP_TABELLA=`grep TP_TABELLA $CONFIG_FILE | awk '{ print $2 }'`
ISTANZA=`grep ISTANZA $CONFIG_FILE | awk '{ print $2 }'`
USER_PW=`grep USER_PW $CONFIG_FILE | awk '{ print $2 }'` 
VER=`grep VER $CONFIG_FILE | awk '{ print $2 }'`
DATA=`grep DATA $CONFIG_FILE | awk '{ print $2 }'`
TODAY=`date "+[%d-%b-%y %H:%M:%S]"`


if [[ $file_sisobd_she_name = "" || $ISTANZA = "" || $USER_PW = "" || $VER = "" || $DATA = "" || $tp_ctl_name = "" || $tp_log_name = "" || $tp_sql_name = "" || $tp_lis_name = "" || $tp_ldr_log = "" || $TP_TABELLA = "" || ! -s $FILE_SISOBD_SHE ]]
then
  echo "$TODAY $0 : qualche valore nullo in CONFIG_FILE o FILE_SISOBD_SHE inesistente (exit 1)">>$INST_PATCH_LOG
  exit 1
fi 

echo "$TODAY $0 : START">>$INST_PATCH_LOG

rm -f $TP_CTL >/dev/null
rm -f $COMODO >/dev/null
rm -f $TP_LOG >/dev/null
rm -f $TP_SQL >/dev/null
rm -f $TP_LIS >/dev/null
rm -f $TP_LDR_LOG >/dev/null

#************************************************************************
# scrivo il control file (che contiene anche i dati)
#************************************************************************
cat > $TP_CTL <<- !
LOAD DATA
INFILE *
APPEND
INTO TABLE $TP_TABELLA
FIELDS TERMINATED BY ' '
(TIPO,NOME,PATCH,DPATCH DATE "dd-mon-yyyy")
BEGINDATA
!

#************************************************************************
# Parsing del sisobd
#************************************************************************
cat $FILE_SISOBD_SHE | grep -vE "siso|_DIP" | awk '{ print $2, $3 }'  >> $COMODO

#************************************************************************
# Aggiungo la data
#************************************************************************
cat $COMODO| while read t n
do
  echo "$t $n $VER $DATA" >> $TP_CTL
done

#************************************************************************
# formatto la lista dei sorgenti per metterla nell'sql
#************************************************************************
ELENCO=`cat $COMODO | awk '{ print $2 }'`
SORGE="("

for sorg in `echo $ELENCO`
do
  SORGE="$SORGE,'$sorg'"
done

SORGENTI=`echo $SORGE | sed '1,$s/\,//'`
SORGENTI="$SORGENTI)"

#************************************************************************
# scrivo l'sql che cancella i sorgenti con versione obsoleta
#************************************************************************
cat > $TP_SQL <<- !
spool $TP_LIS 
delete $TP_TABELLA where nome in $SORGENTI;
commit;
spool off
exit
!
 
#************************************************************************
# lancio l'sql
#************************************************************************
if [[ -s $TP_SQL ]]
then
  echo "$TODAY $0 : Lancio $tp_sql_name ">>$INST_PATCH_LOG
  echo "$0 : Lancio $tp_sql_name" 
  /o/app/oracle/product/7.2.3/bin/sqlplus $USER_PW@$ISTANZA @$TP_SQL >/dev/null 2>&1
else
  echo "$TODAY $0 : $tp_sql_name inesistente (exit 1)">>$INST_PATCH_LOG
  echo "$0 : $tp_sql_name inesistente (exit 1)"
  exit 1
fi

#************************************************************************
# lancio sqlloader
#************************************************************************
if [[ -s $TP_CTL ]]
then
  echo "$TODAY $0 : Lancio $tp_ctl_name ">>$INST_PATCH_LOG
  echo "$0 : Lancio $tp_ctl_name"
  /o/app/oracle/product/7.2.3/bin/sqlldr userid=$USER_PW control=$TP_CTL log=$TP_LDR_LOG >/dev/null 2>&1
else
  echo "$TODAY $0 : $tp_ctl_name inesistente (exit 1)">>$INST_PATCH_LOG
  echo "$0 : $tp_ctl_name inesistente (exit 1)"
  exit 1
fi

rm $COMODO 2>/dev/null
exit 0

