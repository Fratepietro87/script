#!/bin/csh
#******************************************************************
#                InstallaReverse.bat
#
# Goal: script per installare le script per l'ident 
#
# Parameters: $1 nome del database
#             $2 hostaname della macchina su cui installare
#
# Author: Luca Brizzolara, Jenuary 2001
#
#******************************************************************

#******************************************************************
# Set Variabili globali
#******************************************************************
set REVERSE_DIR = "/tst1/ccm_root/REVERSE_SCRIPT/source"
set REVERSE_SCRIPT_DIR = "${REVERSE_DIR}/SCRIPT"
set REVERSE_TRIGGER_DIR = "${REVERSE_DIR}/TRIGGER"
set REVERSE_SCRIPT_REM = "${REVERSE_DIR}/REMOTE_SCRIPT"
set REVERSE_BASE_CONFIG = "${REVERSE_DIR}/CONFIG"
set LISTA_PROGETTI = "ListaProj_RCS"
set LISTA_PROGETTI_LIB = "ListaProj_RCS_LIB"


if ($#argv != 2) then
  echo "USAGE: InstallaReverse.bat DB_NAME hostname"
  exit 1
else
  set DATABASE = $1
endif
set REMOTE_REL_DIR = "TRIGGER_SCRIPT/${DATABASE}"
set REMOTE_CNF_DIR = "${REMOTE_REL_DIR}/cnf"
set HOSTNAME = $2
set CCM51_DB = "${DBAREA}/${DATABASE}"
set TRIGGER_BASE_PATH = "${CCM51_DB}/lib/notify/Unix"
set CONFIG_BASE_PATH = "${CCM51_DB}/lib/notify/cnf"
set REVERSE_CONFIG_DIR = "${REVERSE_BASE_CONFIG}/${DATABASE}"
set DB_LOG_DIR = "${CCM51_DB}/lib/notify/log"

#******************************************************************
# Controllo che esistano il database e il Path delle script
#******************************************************************
if !(-d ${CCM51_DB} ) then
  echo "Operazione di installazione fallita"
  echo "Il database ${CCM51_DB} non esiste"
  echo "Verificare i parametri"
  exit 2
endif
if !(-d ${TRIGGER_BASE_PATH} ) then
  echo "Operazione di installazione fallita"
  echo "Il database ${CCM51_DB} non esiste"
  echo "Verificare i parametri"
  exit 3
endif
if !(-d ${DB_LOG_DIR} ) then
  mkdir -p ${DB_LOG_DIR}
  if !(-d ${DB_LOG_DIR} ) then
    echo "Operazione di installazione fallita"
    echo "Il database ${CCM51_DB} non esiste"
    echo "Verificare i parametri"
    exit 3
  endif
endif

#******************************************************************
# Controllo che sia stato creato il file di configurazione per la 
# lista del progetto
#******************************************************************
if !(-d ${REVERSE_CONFIG_DIR} ) then
  echo "Operazione di installazione fallita"
  echo "Non esiste la directory ${REVERSE_CONFIG_DIR} che deve contenere il file con l'elenco dei progetti"
  echo "Verificare i parametri"
  exit 4
endif
if !(-f ${REVERSE_CONFIG_DIR}/${LISTA_PROGETTI} ) then
  echo "Operazione di installazione fallita"
  echo "Non esiste ${REVERSE_CONFIG_DIR}/${LISTA_PROGETTI}, il file  con l'elenco dei progetti"
  echo "Verificare i parametri"
  exit 5
endif

#******************************************************************
# Se l'hostname e' diverso da omis123 installo solo la parte remota
#******************************************************************
if (`echo ${HOSTNAME} |grep omis123 |wc -l` == 0) then
#******************************************************************
# Provo a creare la directory remota
#******************************************************************
  rsh ${HOSTNAME} -l ccm_root "mkdir -p ${REMOTE_REL_DIR}; chmod 777 ${REMOTE_REL_DIR}"
  set ESITO = ${status}
  if (${ESITO} != 0 ) then
    echo "Operazione di installazione su $2 non riuscita"
    echo "Problemi nella connessione rsh"
    echo "Non sono riuscito a creare la directory ${REMOTE_REL_DIR}"
    exit 6
  endif
#******************************************************************
# Copio i file in remoto, e cambio i permessi
#******************************************************************
  rsh ${HOSTNAME} -l ccm_root "cd ${REMOTE_REL_DIR}; rcp omis123:${REVERSE_SCRIPT_REM}/* ."
  set ESITO = ${status}
  if (${ESITO} != 0 ) then
    echo "Operazione di installazione su $2 non riuscita"
    echo "Problemi nella connessione rsh"
    echo "Non sono riuscito a copiare i file."
    exit 7
  endif
#******************************************************************
# Provo a creare la directory remota per i file di configurazione
#******************************************************************
  rsh ${HOSTNAME} -l ccm_root "mkdir -p ${REMOTE_CNF_DIR}; chmod 777 ${REMOTE_CNF_DIR}"
  set ESITO = ${status}
  if (${ESITO} != 0 ) then
    echo "Operazione di installazione su $2 non riuscita"
    echo "Problemi nella connessione rsh"
    echo "Non sono riuscito a creare la directory ${REMOTE_CNF_DIR}"
    exit 8
  endif
  rsh ${HOSTNAME} -l ccm_root "cd ${REMOTE_CNF_DIR}; rcp -r omis123:${REVERSE_CONFIG_DIR}/${LISTA_PROGETTI} ."
  set ESITO = ${status}
  if (${ESITO} != 0 ) then
    echo "Operazione di installazione su $2 non riuscita"
    echo "Problemi nella connessione rsh"
    echo "Non sono riuscito a copiare il file di configurazione"
    exit 7
  endif
  rsh ${HOSTNAME} -l ccm_root "cd ${REMOTE_CNF_DIR}; rcp -r omis123:${REVERSE_CONFIG_DIR}/${LISTA_PROGETTI_LIB} ."
  set ESITO = ${status}
  if (${ESITO} != 0 ) then
    echo "Operazione di installazione su $2 non riuscita"
    echo "Problemi nella connessione rsh"
    echo "Non sono riuscito a copiare il file di configurazione"
    exit 7
  endif
else
#******************************************************************
# Copio i file nella directory di trigger sostituendo i nomi del db
#******************************************************************
  cat ${REVERSE_SCRIPT_DIR}/AggiornaRCS_script |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/AggiornaRCS_script
  cat ${REVERSE_SCRIPT_DIR}/AggiornaRCS_Lib_script |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/AggiornaRCS_Lib_script
  cat ${REVERSE_SCRIPT_DIR}/Agg_loc_RCS.ksh |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/Agg_loc_RCS.ksh

#******************************************************************
# Cambio i permessi
#******************************************************************
  chmod 755 ${TRIGGER_BASE_PATH}/AggiornaRCS_script
  chmod 755 ${TRIGGER_BASE_PATH}/AggiornaRCS_Lib_script
  chmod 755 ${TRIGGER_BASE_PATH}/Agg_loc_RCS.ksh

#******************************************************************
# Se non esiste la directory di configurazione la creo
#******************************************************************
  if !(-d ${CONFIG_BASE_PATH} ) then
    mkdir ${CONFIG_BASE_PATH}
  endif
  cp ${REVERSE_CONFIG_DIR}/${LISTA_PROGETTI} ${CONFIG_BASE_PATH}/${LISTA_PROGETTI}
  cp ${REVERSE_CONFIG_DIR}/${LISTA_PROGETTI_LIB} ${CONFIG_BASE_PATH}/${LISTA_PROGETTI_LIB}

#******************************************************************
# Sistemo il trigger se necessario
#******************************************************************
  if (`grep AggiornaRCS_script ${TRIGGER_BASE_PATH}/Trig_ui.def |grep -v \# |wc -l` == 0 ) then
    cat ${REVERSE_TRIGGER_DIR}/Delta_Trigger_ui1 >> ${TRIGGER_BASE_PATH}/Trig_ui.def
    if (`grep AggiornaRCS_Lib_script ${TRIGGER_BASE_PATH}/Trig_ui.def |grep -v \# |wc -l` == 0 ) then
      cat ${REVERSE_TRIGGER_DIR}/Delta_Trigger_ui2 >> ${TRIGGER_BASE_PATH}/Trig_ui.def
    endif
  else
    if (`grep AggiornaRCS_Lib_script ${TRIGGER_BASE_PATH}/Trig_ui.def |grep -v \# |wc -l` == 0 ) then
      cat ${REVERSE_TRIGGER_DIR}/Delta_Trigger_ui2 >> ${TRIGGER_BASE_PATH}/Trig_ui.def
    else
      echo "Trig_ui.def gia' corretto"
    endif
  endif
endif

