#!/bin/csh
#******************************************************************
#                InstallaIdent.bat
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
set IDENT_DIR = "/tst1/ccm_root/IDENT/source"
set IDENT_SCRIPT_DIR = "${IDENT_DIR}/SCRIPT"
set IDENT_TRIGGER_DIR = "${IDENT_DIR}/TRIGGER"
set IDENT_SCRIPT_REM = "${IDENT_DIR}/REMOTE_SCRIPT"
set IDENT_BASE_CONFIG = "${IDENT_DIR}/CONFIG"


if ($#argv != 2) then
  echo "USAGE: InstallaIdent.bat DB_NAME hostname"
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
set IDENT_CONFIG_DIR = "${IDENT_BASE_CONFIG}/${DATABASE}"
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
if !(-d ${IDENT_CONFIG_DIR} ) then
  echo "Operazione di installazione fallita"
  echo "Non esiste la directory ${IDENT_CONFIG_DIR} che deve contenere il file con l'elenco dei progetti"
  echo "Verificare i parametri"
  exit 4
endif
if !(-f ${IDENT_CONFIG_DIR}/ListaProj_ident ) then
  echo "Operazione di installazione fallita"
  echo "Non esiste ${IDENT_CONFIG_DIR}/ListaProj_ident, il file  con l'elenco dei progetti"
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
  rsh ${HOSTNAME} -l ccm_root "cd ${REMOTE_REL_DIR}; rcp -r omis123:${IDENT_SCRIPT_REM}/* . ;chmod 777 Utility"
  set ESITO = ${status}
  if (${ESITO} != 0 ) then
    echo "Operazione di installazione su $2 non riuscita"
    echo "Problemi nella connessione rsh"
    echo "Non sono riuscito a copiare i file."
    exit 7
  endif
#******************************************************************
# Provo a creare la directory remota per il file di configurazione
#******************************************************************
  rsh ${HOSTNAME} -l ccm_root "mkdir -p ${REMOTE_CNF_DIR}; chmod 777 ${REMOTE_CNF_DIR}"
  set ESITO = ${status}
  if (${ESITO} != 0 ) then
    echo "Operazione di installazione su $2 non riuscita"
    echo "Problemi nella connessione rsh"
    echo "Non sono riuscito a creare la directory ${REMOTE_CNF_DIR}"
    exit 8
  endif
  rsh ${HOSTNAME} -l ccm_root "cd ${REMOTE_CNF_DIR}; rcp -r omis123:${IDENT_CONFIG_DIR}/ListaProj_ident ."
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
  cat ${IDENT_SCRIPT_DIR}/ModificaIdent |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/ModificaIdent
  cat ${IDENT_SCRIPT_DIR}/CercaPath_script |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/CercaPath_script
  cat ${IDENT_SCRIPT_REM}/InsertNewIdent_script |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/InsertNewIdent_script
  cat ${IDENT_SCRIPT_DIR}/DeleteLog |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/DeleteLog
  cat ${IDENT_SCRIPT_DIR}/LeggiPath_script |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/LeggiPath_script

#******************************************************************
# Cambio i permessi
#******************************************************************
  chmod 755 ${TRIGGER_BASE_PATH}/ModificaIdent
  chmod 755 ${TRIGGER_BASE_PATH}/CercaPath_script
  chmod 755 ${TRIGGER_BASE_PATH}/InsertNewIdent_script
  chmod 755 ${TRIGGER_BASE_PATH}/LeggiPath_script
  chmod 755 ${TRIGGER_BASE_PATH}/DeleteLog

#******************************************************************
# Se non esiste la directory Utility la creo
#******************************************************************
  if !(-d ${TRIGGER_BASE_PATH}/Utility) then
    mkdir ${TRIGGER_BASE_PATH}/Utility
  endif
  cp ${IDENT_SCRIPT_DIR}/Utility/* ${TRIGGER_BASE_PATH}/Utility

#******************************************************************
# Se non esiste la directory di configurazione la creo
#******************************************************************
  if !(-d ${CONFIG_BASE_PATH} ) then
    mkdir ${CONFIG_BASE_PATH}
  endif
  cp ${IDENT_CONFIG_DIR}/ListaProj_ident ${CONFIG_BASE_PATH}/ListaProj_ident

#******************************************************************
# Sistemo il trigger se necessario
#******************************************************************
  if (`grep ModificaIdent ${TRIGGER_BASE_PATH}/Trig_ui.def |grep -v \# |wc -l` == 0 ) then
    cat ${IDENT_TRIGGER_DIR}/Delta_Trigger_ui >> ${TRIGGER_BASE_PATH}/Trig_ui.def
  else
    echo "Trig_ui.def gia' corretto"
  endif
  if (`grep CercaPath_script ${TRIGGER_BASE_PATH}/Trig_eng.def |grep -v \# |wc -l` == 0 ) then
    cat ${IDENT_TRIGGER_DIR}/Delta_Trigger_eng1 >> ${TRIGGER_BASE_PATH}/Trig_eng.def
    if (`grep DeleteLog ${TRIGGER_BASE_PATH}/Trig_eng.def |grep -v \# |wc -l` == 0 ) then
      cat ${IDENT_TRIGGER_DIR}/Delta_Trigger_eng2 >> ${TRIGGER_BASE_PATH}/Trig_eng.def
    endif
  else
    if (`grep DeleteLog ${TRIGGER_BASE_PATH}/Trig_eng.def |grep -v \# |wc -l` == 0 ) then
      cat ${IDENT_TRIGGER_DIR}/Delta_Trigger_eng2 >> ${TRIGGER_BASE_PATH}/Trig_eng.def
    else
      echo "Trig_eng.def gia' corretto"
    endif
  endif
endif

  
