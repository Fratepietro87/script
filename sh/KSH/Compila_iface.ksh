#!/bin/ksh 
#*******************************************************************************
#*                        Compila_iface.csh
#*
#* Goal: Compilare gli oggetti [[form, routine, programmi]] che si trovano in
#*       TEMP_DIR; in seguito i programmi compilati [[quelli in TEMP_DIR e quelli
#*       che utilizzano le routine ricompilate]] vengono copiati nella directory
#*       della consegna.
#*
#* Parametri passati: $1 progetto
#*                    $2 numero_consegna
#*  Modified by: Barbara Battistelli [[Comitsiel]]
#*******************************************************************************
. /u/dsim/.profile
BASE_DIR="/u/dsim/CM45_DIR"
TEMP_DIR="${BASE_DIR}/SVILUPPO"
LISTE_DIR="${BASE_DIR}/LISTE"
MIG_LOCAL_ROOT="/usr/local/MIG_DB_GPM"
LOG_DIR="${BASE_DIR}/LOG"
routine_lista="${LISTE_DIR}/routine.lst"
iface_lista="${LISTE_DIR}/iface.lst"
programmi_da_routine_lista="${LISTE_DIR}/program_routine.lst"
programmi_temp_lista="${LISTE_DIR}/program.tmp"
programmi_lista="${LISTE_DIR}/program.lst"
compila_log="${LOG_DIR}/compila_svil.log"
sviluppo_log="${LOG_DIR}/sviluppo.log"
LANCIAW="${BASE_DIR}/SCRIPT/Lanciawhat.ksh"
LOCK="${LOG_DIR}/file.lock"
TODAY=`date "+[%d-%b-%y %H:%M:%S]"`
#********************************************************************************
# Cancello, se esistenti le liste che poi dovro' utilizzare.
#********************************************************************************
if [[ -f ${compila_log} ]]
then
  mv ${compila_log} ${compila_log}.save
fi
if [[ -f ${routine_lista} ]] 
then
  rm -f ${routine_lista}
fi
if [[ -f ${programmi_temp_lista} ]]
then
  rm -f ${programmi_temp_lista}
fi
if [[ -f ${iface_lista} ]] 
then
  rm -f ${iface_lista}
fi
if [[ -f ${programmi_da_routine_lista} ]] 
then
  rm -f ${programmi_da_routine_lista}
fi
if [[ -f ${programmi_lista} ]] 
then
  rm -f ${programmi_lista}
fi
echo "Fine inizializzazione file"

#*******************************************************************************
# Provo a cancellare la directory contenente le routine; se non ci riesco significa
# che non e' vuoto; allora prdoneo l'elenco delle routine, e per ciascuna, la
# inserisco in siso, la compilo e determino l'elenco dei programmi che usano
# tale routine e per questo sono da ricompilare.
#********************************************************************************
echo "#--------------------------------#" >> ${sviluppo_log}
echo "$TODAY $0 : START" >> ${sviluppo_log}
echo "Comincio ad esaminare le routine" >> ${sviluppo_log}

echo "Comincio ad esaminare le routine" 

rmdir ${TEMP_DIR}/routine
if [[ -d ${TEMP_DIR}/routine ]] 
then
  echo "ho delle routine"
  touch ${programmi_da_routine_lista}
  ls ${TEMP_DIR}/routine > ${routine_lista}
  Elenco_Routine=""
  numero_routine=`cat ${routine_lista} |wc -l`
  i=0
  while [[ $i < ${numero_routine} ]] 
  do
    let i=i+1
    routine_name=`head -n $i ${routine_lista}|tail -n 1`
    if [[ $i > 1 ]] 
    then
      Elenco_Routine="${Elenco_Routine}|${routine_name}"
    else
      Elenco_Routine="${routine_name}"
    fi
  done
  echo "Lancio $LANCIAW" >> ${sviluppo_log}
  $LANCIAW $LOCK $Elenco_Routine  ${programmi_da_routine_lista} &

  i=0
  while [[ $i < ${numero_routine} ]] 
  do
    let i=i+1
    routine_name=`head -n $i ${routine_lista}|tail -n 1`
    nomer=`echo ${routine_name}| awk -F"." '{ print $1 }'` 
    rm -f /u/dsim/siso/h/${nomer}.o
    siso rm ${TEMP_DIR}/routine/${routine_name} >> ${compila_log} 2>&1
#    rm -f ${TEMP_DIR}/routine/${routine_name} 
    siso r1 ${routine_name} >> ${compila_log} 2>&1
    if [[ `cat ${compila_log}|grep "Error"|grep "exit" |grep "code"|wc -l` != 0  ]] 
    then
      PID=`ps -ef | grep -v grep| grep $LANCIAW|awk '{print $2}'`
      kill -9 $PID
      exit 1
    fi
  done

  while [[ -f $LOCK ]]
  do
    sleep 5
  done

  sort -u ${programmi_da_routine_lista} > ${programmi_temp_lista}
  mv ${programmi_temp_lista} ${programmi_da_routine_lista}
fi
echo "Fine esame routine" 


#*******************************************************************************
# Se la directory program non e' vuota, copio ogni programma in esso contenuto,
# dentro siso.
#*******************************************************************************
echo "Comincio ad esaminare i programmi" >> ${sviluppo_log}
echo "Comincio ad esaminare i programmi"
rmdir ${TEMP_DIR}/interface
if [[ -d ${TEMP_DIR}/interface ]] 
then
  echo "Ho delle interfacce"
  ls ${TEMP_DIR}/interface > ${iface_lista}
  numero_interfacce=`cat ${iface_lista} |wc -l`
  i=0
  while [[ $i < ${numero_interfacce} ]]
  do
    let i=i+1 
    nome_interfaccia=`head -n $i ${iface_lista}|tail -n 1` 
    siso pm ${TEMP_DIR}/interface/${nome_programma} >> ${compila_log} 2>&1 
#    rm -f ${TEMP_DIR}/interface/${nome_programma} 
  done
fi
echo "Fine esame interfacce" 

#*******************************************************************************
# Ottengo una unica lista di programmi da compilare, e li compilo tutti. 
#*******************************************************************************
echo "Compilo tutti i programmi" >> ${sviluppo_log}

echo "Compilo tutti i programmi"


if [[ -f ${programmi_da_routine_lista} ]]
then
  cp ${programmi_da_routine_lista} ${programmi_lista}
fi
cat ${iface_lista} >> ${programmi_lista}
sort -u ${programmi_lista} > ${programmi_temp_lista}
mv ${programmi_temp_lista} ${programmi_lista}
if [[ `cat ${programmi_lista} |wc -l` != 0 ]] 
then
  numero_programmi=`cat ${programmi_lista} |wc -l`
  echo "Numero programmi: ${numero_programmi}"
  i=0
  while [[ $i < ${numero_programmi} ]]
  do
    let i=i+1 
    nome_programma=`head -n $i ${programmi_lista}|tail -n 1`
    echo "nome_programma: ${nome_programma}"
    nomep=`echo ${nome_programma}| awk -F"." '{ print $1 }'` 
    echo "nomep: ${nomep}"
    rm -f /u/dsim/bin/nomep
    siso p1 ${nome_programma} > ${compila_log} 2>${compila_log}
    if [[ `cat ${compila_log}|grep "Error"|grep "exit" |grep "code"|wc -l` != 0  ]] 
    then
      mkdir ${TEMP_DIR}/routine &
      echo "Esco con errore"
      exit 1
    fi
  done
fi
echo "Fine esame programmi"

#*******************************************************************************
# ricreo le directory temporanee per le successive compilazioni.
#*******************************************************************************
mkdir ${TEMP_DIR}/interface ${TEMP_DIR}/routine &

#*******************************************************************************
# Copio tutti i programmi eventualmente ricompilati nella directory di consegna.
#*******************************************************************************
echo "Copio gli eseguibili nelle directory di consegna" >> ${sviluppo_log}
if [[ -f ${programmi_lista} ]] 
then
  DESTINATION_PATH="${MIG_LOCAL_ROOT}/$1$2/u/dsim/bin"
  mkdir -p ${DESTINATION_PATH}
  cd /u/dsim/bin
  numero_programmi=`cat ${programmi_lista}|wc -l`
  i=0
  while [[  $i < ${numero_programmi}  ]]
  do
    let i=i+1 
    nome_programma=`head -n $i ${programmi_lista}|tail -n 1| awk -F"." '{print $1}'`
    if [[ -f /u/iface/bin/${nome_programma} ]] 
    then
      cp ./${nome_programma} /u/iface/bin
    fi
    cp ./${nome_programma} ${DESTINATION_PATH}
  done
  if [[ -f ${iface_lista} ]] 
  then
    numero_interfacce=`cat ${iface_lista}|wc -l`
    j=0
    while [[ $j < ${numero_interfacce} ]]
    do
      let j=j+1 
      nome_interfaccia=`head -n $j ${iface_lista}|tail -n 1 | awk -F"." '{print $1}'`
      cp ./${nome_interfaccia} /u/iface/bin
    done
  fi
  cd
fi
echo "$TODAY $0 : STOP" >> ${sviluppo_log}

exit 0
