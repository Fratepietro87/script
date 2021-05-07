#!/bin/csh
#******************************************************************
#                InstallaScript.bat
#
# Goal: script per installare le script per costruire i file con
#       le versioni dei progetti utilizzati nella compilazione
#       degli eseguibili
#
# Parameters: $1 nome del database
#
# Author: Luca Brizzolara, February 2001
#
#******************************************************************

#******************************************************************
# Set Variabili globali
#******************************************************************
set DIR_BASE_SOURCE = "/tst1/ccm_root/LISTA_COMPONENTI/source"
set SOURCE_TRIGGER_DIR = "${DIR_BASE_SOURCE}/TRIGGER"
set MAILER_SOURCE = "/tst1/ccm_root/MAILER"

if ($#argv != 1) then
  echo "USAGE: InstallaScript.bat DB_NAME"
  exit 1
else
  set DATABASE = $1
endif
set LISTA_CONFIG_DIR = "${DIR_BASE_SOURCE}/CONFIG/${DATABASE}"

#******************************************************************
# Verifico l'esistenza del file dei parametri
#******************************************************************
set DB_NAME = "${DBAREA}/${DATABASE}"
if !(-d ${DB_NAME}) then
  echo "ERRORE:Il database ${DB_NAME} NON esiste."
  echo "Verificare i parametri."
  echo "Operazione annullata"
  exit 1
endif

if !(-d ${LISTA_CONFIG_DIR}) then
  echo "ERRORE:La directory ${LISTA_CONFIG_DIR}  che dovrebbe contenere il file di configurazione NON esiste."
  echo "Verificare i parametri."
  echo "Operazione annullata"
  exit 1
endif

echo "Check Dei Parametri OK"

###################################################################
# Inizio fase di istallazione dell'automa.
###################################################################

#******************************************************************
# Creo le directory eventualmente mancanti
#******************************************************************
set DEPOT_BASE_PATH = "${DB_NAME}/lib/notify/LISTE_VERSIONI"
set DATABASE_LOG_DIR = "${DB_NAME}/lib/notify/log"
set TRIGGER_BASE_PATH = "${DB_NAME}/lib/notify/Unix"
if !(-d ${DEPOT_BASE_PATH} )then
  mkdir ${DEPOT_BASE_PATH}
  if !(-d ${DEPOT_BASE_PATH} ) then
    echo "Non riesco a creare ${DEPOT_BASE_PATH}"
    echo "Operazione di installazione fallita"
    exit 2
  endif
endif

if !(-d ${DEPOT_BASE_PATH}/TEMP )then
  mkdir ${DEPOT_BASE_PATH}/TEMP
  if !(-d ${DEPOT_BASE_PATH}/TEMP ) then
    echo "Non riesco a creare ${DEPOT_BASE_PATH}/TEMP"
    echo "Operazione di installazione fallita"
    exit 4
  endif
endif

if !(-d ${DEPOT_BASE_PATH}/MIGRATE )then
  mkdir ${DEPOT_BASE_PATH}/MIGRATE
  if !(-d ${DEPOT_BASE_PATH}/MIGRATE ) then
    echo "Non riesco a creare ${DEPOT_BASE_PATH}/MIGRATE"
    echo "Operazione di installazione fallita"
    exit 5
  endif
endif

if !(-d ${DEPOT_BASE_PATH}/CONFIG )then
  mkdir ${DEPOT_BASE_PATH}/CONFIG
  if !(-d ${DEPOT_BASE_PATH}/CONFIG ) then
    echo "Non riesco a creare ${DEPOT_BASE_PATH}/CONFIG"
    echo "Operazione di installazione fallita"
    exit 6
  endif
endif

if !(-d ${DEPOT_BASE_PATH}/FLAG )then
  mkdir ${DEPOT_BASE_PATH}/FLAG
  if !(-d ${DEPOT_BASE_PATH}/FLAG ) then
    echo "Non riesco a creare ${DEPOT_BASE_PATH}/FLAG"
    echo "Operazione di installazione fallita"
    exit 6
  endif
endif

set MAIL_BASE_PATH = "${DB_NAME}/lib/notify/Mail"
if !(-d ${MAIL_BASE_PATH} )then
  mkdir ${MAIL_BASE_PATH}
  if !(-d ${MAIL_BASE_PATH} ) then
    echo "Non riesco a creare ${MAIL_BASE_PATH}"
    echo "Operazione di installazione fallita"
    exit 7
  endif
endif

if !(-d ${MAIL_BASE_PATH}/log )then
  mkdir ${MAIL_BASE_PATH}/log
  if !(-d ${MAIL_BASE_PATH}/log ) then
    echo "Non riesco a creare ${MAIL_BASE_PATH}/log"
    echo "Operazione di installazione fallita"
    exit 8
  endif
endif

if !(-d ${MAIL_BASE_PATH}/Address )then
  mkdir ${MAIL_BASE_PATH}/Address
  if !(-d ${MAIL_BASE_PATH}/Address ) then
    echo "Non riesco a creare ${MAIL_BASE_PATH}/Address"
    echo "Operazione di installazione fallita"
    exit 9
  endif
endif

#******************************************************************
# Verifico che sia stato creato l'opportuno file di configurazione
# Nel caso ci sia lo copio modificandone il nome in ListaElementi.cfg
#******************************************************************
if !(-f ${LISTA_CONFIG_DIR}/ListaElementi.cfg) then
  echo "ERRORE: Non e' stato creato il file di configurazione per il database ${DATABASE}"
  echo "Il nome del file cercato e' ${LISTA_CONFIG_DIR}/ListaElementi.cfg"
  echo "Operazione di istallazione automa fallita"
  exit 30
else
  cp ${LISTA_CONFIG_DIR}/ListaElementi.cfg ${DEPOT_BASE_PATH}/CONFIG
endif

#******************************************************************
# Copio la script per da agganciare al trigger
#******************************************************************
cat ${SOURCE_TRIGGER_DIR}/RicercaListaVersioni |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/RicercaListaVersioni
chmod 755 ${TRIGGER_BASE_PATH}/RicercaListaVersioni
cat ${MAILER_SOURCE}/sun_mail |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/sun_mail
chmod 755 ${TRIGGER_BASE_PATH}/sun_mail
cat ${MAILER_SOURCE}/genera_mail |nawk -v NEW_NAME="${DATABASE}" '{ gsub("SELESTA",NEW_NAME); print $0 }' > ${TRIGGER_BASE_PATH}/genera_mail
chmod 755 ${TRIGGER_BASE_PATH}/genera_mail

#******************************************************************
# Aggiungo al Trig_eng.def la sessione per richiamare la script 
# sopra se necessario
#******************************************************************
if (`grep RicercaListaVersioni ${TRIGGER_BASE_PATH}/Trig_eng.def |grep -v \# |wc -l` == 0 ) then
  cat ${SOURCE_TRIGGER_DIR}/Delta_Trigger_Ricerca >> ${TRIGGER_BASE_PATH}/Trig_eng.def
else
  echo "Trig_eng.def gia' corretto"
endif

