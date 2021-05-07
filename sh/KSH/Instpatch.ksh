#!/bin/ksh
#########################################################################
# Author: Barbara Battistelli - Comitsiel
# Modified: Luca Brizzolara - Selesta
# Goal  : esecuzione delle operazioni di installazione della patch
#########################################################################
#			NOTE
# Questa script viene pilotata dal file di configurazine Config_file e
# provvede ad effettuare tutte le operazioni necessarie al
# completamento dell'installazione di una patch, richiamando a sua
# volta le seguenti scripts:
# (1) Pgmincl.ksh
#     genera una lista con i programmi che devono essere ricompilati
#     perche' la patch contiene delle routine
# (2) Crealista.ksh
#     genera tre files upd.lista.$VER, upd.iface.lista.$VER,
#     udp.ch.iface.$VER, che servono per fare il tar dell'ambiente aggiornato
#     e trasferirlo sulle altre macchine
# (3) Chkbinfrm.ksh
#     genera due liste contenenti rispettivamente i programmi e le form che
#     risultano ancora scompilati
# (4) Creasyn.ksh
#     Crea i sinonimi per i nuovi oggetti creati da patch.sql e se c'e'
#     stopro.sql rigenera i synonimi per tutti i package
# (5) Ricompila.ksh
#     ricompila tutti i sorgenti che sono rimasti scompilati o che usano
#     le routine presenti nella patch
# (6) Tpatch.ksh
#     popola la tabella TPATCH aggiornando la versione dei sorgenti
#########################################################################
. /u/dsim/.profile

CM45_DIR=/u/dsim/CM45_DIR
SCRIPT_DIR=${CM45_DIR}/SCRIPT
LOG_DIR=${CM45_DIR}/LOG
LISTA_DIR=${CM45_DIR}/LISTE


INST_PATCH_LOG=${LOG_DIR}/instpatch.log
CONFIG_FILE=${SCRIPT_DIR}/Config_file
if [[ ! -f $CONFIG_FILE ]]
then
  echo "Il $CONFIG_FILE non esiste. Controllare."  >> $INST_PATCH_LOG
  exit 5
fi

if [[ ! -r $CONFIG_FILE ]]
then
  echo "Il $CONFIG_FILE non e' leggibile. Controllare i permessi."  >> $INST_PATCH_LOG
  exit 5
fi

#****************************************************
# Leggo le variabili dal CONFIG_FILE; nel caso dei
# file, una volta ottenutone il nome, vi aggiungo
# anche il path per referenziarli con il loro path
# assoluto.
#****************************************************
VER=`grep VER $CONFIG_FILE | awk '{ print $2 }'`

#****************************************************
# Ricavo i nomi delle shell da lanciare
#****************************************************
pgmincl_ksh_name=`grep PGMINCL_KSH $CONFIG_FILE | awk '{ print $2 }'`
PGMINCL_KSH=${SCRIPT_DIR}/${pgmincl_ksh_name}

crealista_ksh_name=`grep CREALISTA_KSH $CONFIG_FILE | awk '{ print $2 }'`
CREALISTA_KSH=${SCRIPT_DIR}/${crealista_ksh_name}

chkbinfrm_ksh_name=`grep CHKBINFRM_KSH $CONFIG_FILE | awk '{ print $2 }'`
CHKBINFRM_KSH=${SCRIPT_DIR}/${chkbinfrm_ksh_name}

ricompila_ksh_name=`grep RICOMPILA_KSH $CONFIG_FILE | awk '{ print $2 }'`
RICOMPILA_KSH=${SCRIPT_DIR}/${ricompila_ksh_name}

creasyn_ksh_name=`grep CREASYN_KSH $CONFIG_FILE | awk '{ print $2 }'`
CREASYN_KSH=${SCRIPT_DIR}/${creasyn_ksh_name}

tpatch_ksh_name=`grep TPATCH_KSH $CONFIG_FILE | awk '{ print $2 }'`
TPATCH_KSH=${SCRIPT_DIR}/${tpatch_ksh_name}

#****************************************************
# Ricavo i nomi delle liste e dei log
#****************************************************
check_frm_out_name=`grep CHECK_FRM_OUT $CONFIG_FILE | awk '{ print $2 }'`
CHECK_FRM_OUT=${LISTA_DIR}/${check_frm_out_name}

check_bin_out_name=`grep CHECK_BIN_OUT $CONFIG_FILE | awk '{ print $2 }'`
CHECK_BIN_OUT=${LISTA_DIR}/${check_bin_out_name}

upd_lista_name=`grep UPD_LISTA $CONFIG_FILE | awk '{ print $2 }'`
UPD_LISTA=${LISTA_DIR}/${upd_lista_name}

upd_iface_lista_name=`grep UPD_IFACE_LISTA $CONFIG_FILE | awk '{ print $2 }'`
UPD_IFACE_LISTA=${LISTA_DIR}/${upd_iface_lista_name}

upd_iface_ch_lista_name=`grep UPD_IFACE_CH_LISTA $CONFIG_FILE | awk '{ print $2 }'`
UPD_IFACE_CH_LISTA=${LISTA_DIR}/${upd_iface_ch_lista_name}

VER=`grep VER $CONFIG_FILE | awk '{ print $2 }'`

ricompila_log_name=`grep RICOMPILA_LOG $CONFIG_FILE | awk '{ print $2 }'`
RICOMPILA_LOG=${LOG_DIR}/${ricompila_log_name}

pgmincl_out_name=`grep PGMINCL_OUT $CONFIG_FILE | awk '{ print $2 }'`
PGMINCL_OUT=${LISTA_DIR}/${pgmincl_out_name}

crea_pkg_syn_lis_name=`grep CREA_PKG_SYN_LIS $CONFIG_FILE | awk '{ print $2 }'`
CREA_PKG_SYN_LIS=${LISTA_DIR}/${crea_pkg_syn_lis_name}

crea_pub_syn_lis_name=`grep CREA_PUB_SYN_LIS $CONFIG_FILE | awk '{ print $2 }'`
CREA_PUB_SYN_LIS=${LISTA_DIR}/${crea_pub_syn_lis_name}

crea_syn_log_name=`grep CREA_SYN_LOG $CONFIG_FILE | awk '{ print $2 }'`
CREA_SYN_LOG=${LOG_DIR}/${crea_syn_log_name}

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


TODAY=`date "+[%d-%b-%y %H:%M:%S]"`
VER=`grep VER $CONFIG_FILE | awk '{ print $2 }'`

#****************************************************
# controllo che tutte le var siano definite
#****************************************************
if [[  $pgmincl_ksh_name = "" || $crealista_ksh_name = "" || $chkbinfrm_ksh_name = "" || $ricompila_ksh_name = "" || $creasyn_ksh_name = "" || $tpatch_ksh_name = "" ]]
then
  echo "Warning! qualche variabile nel CONFIG_FILE non e' definita:" >> $INST_PATCH_LOG
  echo "Controllare in CONFIG_FILE: PGMINCL_KSH, CREALISTA_KSH, CHKBINFRM_KSH, RICOMPILA_KSH, CREASYN_KSH" >> $INST_PATCH_LOG
  exit 2
fi

#****************************************************
# controllo che tutte le shell esistano
#****************************************************
if [[ ! -s $PGMINCL_KSH || ! -s $CREALISTA_KSH || ! -s $CHKBINFRM_KSH || ! -s $RICOMPILA_KSH || ! -s $CREASYN_KSH || ! -s $TPATCH_KSH ]]
then
  echo "Warning, uno o piu' delle seguenti shell non esiste:" >>$INST_PATCH_LOG
  echo "$pgmincl_ksh_name, $crealista_ksh_name, $chkbinfrm_ksh_name, $ricompila_ksh_name, creasyn_ksh_name, $tpatch_ksh_name" >> $INST_PATCH_LOG
  exit 3
fi

echo "***************************************************" >> $INST_PATCH_LOG 
echo "$TODAY $0 - PATCH $VER ">>$INST_PATCH_LOG
echo "***************************************************" >> $INST_PATCH_LOG
echo " $TODAY: Inizio attivita' per installazione patch $VER"

#****************************************************
# (1) Lancio PGMINCL_KSH
#****************************************************
#echo "PGMINCL_KSH"
#b=""
#until [[ $b =  "y"  ]]
#do
#read b?"continuo?"
#done


echo "$TODAY $0 - Lancio $pgmincl_ksh_name" >> $INST_PATCH_LOG
echo "(1) Lancio $pgmincl_ksh_name..."
$PGMINCL_KSH
if [[ $? -ne 0 ]]
then
  echo "$TODAY $0 - $pgmincl_ksh_name terminato in modo anomalo (exit 1)" >> $INST_PATCH_LOG
  exit 1
fi


#****************************************************
# (2) Lancio CREALISTA_KSH
#****************************************************
#echo "CREALISTA_KSH"
#b=""
#until [[ $b =  "y"  ]]
#do
#read b?"continuo?"
#done

echo "$TODAY $0 - Lancio $crealista_ksh_name" >> $INST_PATCH_LOG 
echo "(2) Lancio $crealista_ksh_name..."
$CREALISTA_KSH
if [[ $? -ne 0 ]]
then
  echo "$TODAY $0 - $crealista_ksh_name terminato in modo anomalo (exit 1)" >> $INST_PATCH_LOG
  exit 1
fi


#****************************************************
# (3) Lancio CHKBINFRM_KSH
#****************************************************
#echo "CHKBINFRM_KSH"
#b=""
#until [[ $b =  "y"  ]]
#do
#read b?"continuo?"
#done

echo "$TODAY $0 - Lancio $chkbinfrm_ksh_name" >> $INST_PATCH_LOG
echo "(2) Lancio $chkbinfrm_ksh_name..."
$CHKBINFRM_KSH
if [[ $? -ne 0 ]]
then
  echo "$TODAY $0 - $chkbinfrm_ksh_name terminato in modo anomalo (exit 1)" >> $INST_PATCH_LOG
  exit 1
fi

#****************************************************
# (4) Lancio RICOMPILA_KSH
#****************************************************
#echo "RICOMPILA_KSH"
#b=""
#until [[ $b =  "y"  ]]
#do
#read b?"continuo?"
#done

echo "$TODAY $0 - Lancio $ricompila_ksh_name" >> $INST_PATCH_LOG
echo "(2) Lancio $ricompila_ksh_name..."
$RICOMPILA_KSH
if [[ $? -ne 0 ]]
then
  echo "$TODAY $0 - $ricompila_ksh_name terminato in modo anomalo (exit 1)" >> $INST_PATCH_LOG
  exit 1
fi

#****************************************************
# (5) Lancio CREASYN_KSH
#****************************************************
#echo "CREASYN_KSH"
#b=""
#until [[ $b =  "y"  ]]
#do
#read b?"continuo?"
#done

echo "$TODAY $0 - Lancio $creasin_ksh_name" >> $INST_PATCH_LOG
echo "(2) Lancio $creasin_ksh_name..."
$CREASYN_KSH
if [[ $? -ne 0 ]]
then
  echo "$TODAY $0 - $creasin_ksh_name terminato in modo anomalo (exit 1)" >> $INST_PATCH_LOG
  exit 1
fi

#****************************************************
# (6) Lancio TPATCH_KSH
#****************************************************
#echo "TPATCH_KSH"
#b=""
#until [[ $b =  "y"  ]]
#do
#read b?"continuo?"
#done

echo "$TODAY $0 - Lancio $tpatch_ksh_name" >>$INST_PATCH_LOG
echo "(2) Lancio $tpatch_ksh_name..."
$TPATCH_KSH
if [[ $? -ne 0 ]]
then
  echo "$TODAY $0 - $tpatch_ksh_name terminato in modo anomalo (exit 1)" >> $INST_PATCH_LOG
  exit 1
fi

echo "$TODAY $0 - DONE !!! (exit 0)" >> $INST_PATCH_LOG

echo "" >> $INST_PATCH_LOG
echo "" >> $INST_PATCH_LOG

mv $CHECK_FRM_OUT $CHECK_FRM_OUT.$VER 2>/dev/null
mv $CHECK_BIN_OUT $CHECK_BIN_OUT.$VER 2>/dev/null
mv $UPD_LISTA $UPD_LISTA.$VER 2>/dev/null
mv $UPD_IFACE_LISTA $UPD_IFACE_LISTA.$VER 2>/dev/null
mv $UPD_IFACE_CH_LISTA $UPD_IFACE_CH_LISTA.$VER 2>/dev/null
mv $RICOMPILA_LOG $RICOMPILA_LOG.$VER 2>/dev/null
mv $PGMINCL_OUT $PGMINCL_OUT.$VER 2>/dev/null
mv $CREA_PKG_SYN_LIS $CREA_PKG_SYN_LIS.$VER 2>/dev/null
mv $CREA_PUB_SYN_LIS $CREA_PUB_SYN_LIS.$VER 2>/dev/null
mv $CREA_SYN_LOG $CREA_SYN_LOG.$VER 2>/dev/null
mv $TP_CTL $TP_CTL.$VER 2>/dev/null
mv $TP_LOG $TP_LOG.$VER 2>/dev/null
mv $TP_SQL $TP_SQL.$VER 2>/dev/null
mv $TP_LIS $TP_LIS.$VER 2>/dev/null
mv $TP_LDR_LOG $TP_LDR_LOG.$VER 2>/dev/null

exit 0

