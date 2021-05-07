#!/bin/ksh -x
#          DO NOT CHANGE THE NAME OF SHELL
########################################################################
# Author: Barbara Battistelli - Comitsiel
# Modified: Luca Brizzolara - Selesta
# Goal  : Crea i sinonimi per i nuovi oggetti della patch
########################################################################

#**************************************************************
# Variabili
#**************************************************************
. /u/dsim/.profile
CM45_DIR=/u/dsim/CM45_DIR
SCRIPT_DIR=${CM45_DIR}/SCRIPT
LOG_DIR=${CM45_DIR}/LOG
LISTA_DIR=${CM45_DIR}/LISTE
SISO_DIR=/u/dsim/siso
SQL_DIR=/u/dsim/sql
INST_PATCH_LOG=${LOG_DIR}/instpatch.log
CONFIG_FILE=${SCRIPT_DIR}/Config_file


file_sisobd_she_name=`grep FILE_SISOBD_SHE $CONFIG_FILE | awk '{ print $2 }'`
FILE_SISOBD_SHE=${SISO_DIR}/${file_sisobd_she_name}

patch_sql_name=`grep PATCH_SQL $CONFIG_FILE | awk '{ print $2 }'`
PATCH_SQL=${SQL_DIR}/${patch_sql_name}

ISTANZA=`grep ISTANZA $CONFIG_FILE | awk '{ print $2 }'`
USER_PW=`grep USER_PW $CONFIG_FILE | awk '{ print $2 }'`

scr_pkg_syn_sql_name=`grep SCR_PKG_SYN_SQL $CONFIG_FILE | awk '{ print $2 }'`
SCR_PKG_SYN_SQL=${LISTA_DIR}/${scr_pkg_syn_sql_name}

crea_pkg_syn_sql_name=`grep CREA_PKG_SYN_SQL $CONFIG_FILE | awk '{ print $2 }'`
CREA_PKG_SYN_SQL=${LISTA_DIR}/${crea_pkg_syn_sql_name}

crea_pkg_syn_lis_name=`grep CREA_PKG_SYN_LIS $CONFIG_FILE | awk '{ print $2 }'`
CREA_PKG_SYN_LIS=${LISTA_DIR}/${crea_pkg_syn_lis_name}

crea_pub_syn_sql_name=`grep CREA_PUB_SYN_SQL $CONFIG_FILE | awk '{ print $2 }'`
CREA_PUB_SYN_SQL=${LISTA_DIR}/${crea_pub_syn_sql_name}

crea_pub_syn_lis_name=`grep CREA_PUB_SYN_LIS $CONFIG_FILE | awk '{ print $2 }'`
CREA_PUB_SYN_LIS=${LISTA_DIR}/${crea_pub_syn_lis_name}

STOPRO_SQL=`grep STOPRO_SQL $CONFIG_FILE | awk '{ print $2 }'`

crea_syn_log_name=`grep CREA_SYN_LOG $CONFIG_FILE | awk '{ print $2 }'`
CREA_SYN_LOG=${LOG_DIR}/${crea_syn_log_name}


TODAY=`date "+[%d-%b-%y %H:%M:%S]"`

echo "$TODAY $0 : START">>$INST_PATCH_LOG

if [[ $patch_sql_name = "" || $file_sisobd_she_name = "" || $ISTANZA = "" || $USER_PW = ""|| $scr_pkg_syn_sql_name = "" || $crea_pkg_syn_sql_name = "" || $crea_pkg_syn_lis_name = "" || $crea_pub_syn_sql_name = "" || $crea_pub_syn_lis_name = "" || $STOPRO_SQL = "" || $CREA_SYN_LOG = "" ]]
then
  echo "$TODAY $0 : PATCH_SQL o FILE_SISOBD_SHE o ISTANZA o USER_PW o SCR_PKG_SYN_SQL o CREA_PKG_SYN_SQL o CREA_PKG_SYN_LIS o CREA_PUB_SYN_SQL o CREA_PUB_SYN_LIS o STOPRO_SQL  o CREA_SYN_LOG con valore NULL --> controlla CONFIG_FILE (exit 1)">>$INST_PATCH_LOG
  exit 1
fi

rm $SCR_PKG_SYN_SQL 2>/dev/null
rm $CREA_PKG_SYN_SQL 2>/dev/null
rm $CREA_PKG_SYN_LIS 2>/dev/null
rm $CREA_PUB_SYN_SQL 2>/dev/null
rm $CREA_PUB_SYN_LIS 2>/dev/null

echo "set echo on" >> $CREA_PUB_SYN_SQL
echo "spool $CREA_PUB_SYN_LIS" >> $CREA_PUB_SYN_SQL

#**************************************************************
# Nuovi Oggetti creati dalla patch.sql
#**************************************************************
#----------------------------------------------------
ELENCO=`grep -E -i "create table|create view|create sequence" $PATCH_SQL | awk '{ print $3 }'`

if [[ $ELENCO != "" ]]
then
  for obj in `echo $ELENCO`
  do
    echo "CREATE PUBLIC SYNONYM $obj FOR DSIM.$obj" >> $CREA_PUB_SYN_SQL
  done
  echo "spool off" >> $CREA_PUB_SYN_SQL
  echo "exit" >> $CREA_PUB_SYN_SQL

#**************************************************************
# Lancio sql che crea i sinonimi per oggetti della patch.sql
#**************************************************************
  echo "$TODAY $0 : Lancio $crea_pub_syn_sql_name">>$INST_PATCH_LOG
  sqlplus $USER_PW@$ISTANZA @$CREA_PUB_SYN_SQL >> $CREA_SYN_LOG 2>&1
else
  echo "$TODAY $0 Nessun nuovo oggetto in patch.sql"  >>$INST_PATCH_LOG
fi

#**************************************************************
# Package
#**************************************************************
if [[ "`grep $STOPRO_SQL $FILE_SISOBD_SHE 2>/dev/null`" = "" ]]
then
  echo "$TODAY $0 : END (stopro.sql non presente nella patch) --> (exit 0)">>$INST_PATCH_LOG
  exit 0
fi


#**************************************************************
# Creo l'sql che crea l'sql per i sinonimi dei package
#**************************************************************

cat > $SCR_PKG_SYN_SQL <<- END
set echo off
set heading off
set feedback off
set pagesize 0
spool $CREA_PKG_SYN_SQL
select 'set echo on'
from dual
;
select 'spool $CREA_PKG_SYN_LIS' from dual
;
select 'create public synonym '||object_name||' for DSIM.'||object_name||';'
from user_objects
where object_type = 'PACKAGE'
;
select 'spool off' from dual
;
select 'exit' from dual
;
spool off
exit
END

#*************** fine sql ***********************

#**************************************************************
# lancio SCR_PKG_SYN.SQL sql che crea sql per package
#**************************************************************
echo "$TODAY $0 : Lancio $scr_pkg_syn_sql_name">>$INST_PATCH_LOG
sqlplus $USER_PW@$ISTANZA @$SCR_PKG_SYN_SQL >> $CREA_SYN_LOG 2>&1
if [[ -s $CREA_PKG_SYN_SQL ]]
then
#**************************************************************
# lancio CREA_PKG_SYN_SQL che crea i sinonimi per i package
#**************************************************************
  echo "$TODAY $0 : Lancio $crea_pkg_syn_sql_name">>$INST_PATCH_LOG
  sqlplus $USER_PW@$ISTANZA @$CREA_PKG_SYN_SQL >> $CREA_SYN_LOG 2>&1
  echo "$TODAY $0 : END --> (exit 0)">>$INST_PATCH_LOG
  exit 0
else
  echo "$TODAY $0 : file $crea_pkg_syn_sql_name inesistente (exit 1)">>$INST_PATCH_LOG
  exit 1
fi
