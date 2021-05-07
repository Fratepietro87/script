#***************************************************************
#* 			CreaListaBind.sh
#*
#* Goal: creare la lista dei comandi di bind per la macchina
#*       passata come parametro
#*
#* Parameters: $1 Nome della macchina
#*             $2 Nome del progetto
#*             $3 ListaSer con path
#*
#* Author: Luca Brizzolara, Selesta
#* Date: July 2004 
#***************************************************************

if test -n $1 -a -n $2
then
  MachineName=$1
  ProjectName=$2
  SerList=$3
else
  echo "ERRORE nel lancio della script."
  echo "Usage: CreaListaBind.sh Nome_della_macchina Nome_del_Progetto Lista_SER_con_path"
  exit 1
fi

#***************************************************************
# Definisco il nome del file con l'elenco delle macchine
#***************************************************************
LIST_MACHINE_PATH=???
LIST_MACHINE_NAME=machine_list.txt
LIST_MACHINE_FILE=${LIST_MACHINE_PATH}/${LIST_MACHINE_NAME}

#***************************************************************
# Controllo l'esistenza del file con la lista dei parametri per ogni macchina
#***************************************************************
if [ ! -r ${LIST_MACHINE_FILE} ]
then
  echo "Manca il file ${LIST_MACHINE_FILE} o non ci sono i permessi di lettura"
  exit 2
fi

#***************************************************************
# Controllo che ci sia la riga per la macchina
#***************************************************************
if [ `grep ${MachineName} ${LIST_MACHINE_FILE} |wc -l` = 1 ]
then
  FilePathOnMachine=`grep ${MachineName} ${LIST_MACHINE_FILE} | awk -F: '{ print $2 }'`
  MachineApplServerPrefix=`grep ${MachineName} ${LIST_MACHINE_FILE} | awk -F: '{ print $3 }'`
else
  echo "ERRORE: la macchina indicata non e' censita nel file ${LIST_MACHINE_FILE}"
  exit 3
fi

#***************************************************************
# Controllo l'esistenza della lista dei SER
#***************************************************************
if [ ! -r ${SerList} ]
then
  echo "Manca il file ${LIST_MACHINE_FILE} o non ci sono i permessi di lettura"
  exit 4
fi

#***************************************************************
# Definisco il nome del file con i dati del progetto
#***************************************************************
PROJECT_FILE_PATH=??
PROJECT_FILE_NAME=${ProjectName}.lst
FILE_PROJECT=${PROJECT_FILE_PATH}/${PROJECT_FILE_NAME}

#***************************************************************
# Controllo l'esistenza del file con la lista dei parametri per ogni macchina
#***************************************************************
if [ ! -r ${FILE_PROJECT} ]
then
  echo "Manca il file ${FILE_PROJECT} o non ci sono i permessi di lettura"
  exit 5
else
  APPL_SUFFIX=`cat ${FILE_PROJECT} |awk -F: '{ print $2 }'`
  DB2_DATASOURCE_NAME=`cat ${FILE_PROJECT} |awk -F: '{ print $3 }'`
  CICS_DATASOURCE_NAME=`cat ${FILE_PROJECT} |awk -F: '{ print $4 }'`
  SISTEM_DB2=`cat ${FILE_PROJECT} |awk -F: '{ print $5 }'`
  QUALIFIER_DB2=`cat ${FILE_PROJECT} |awk -F: '{ print $6 }'`
  OWNER_DB2=`cat ${FILE_PROJECT} |awk -F: '{ print $7 }'`
fi

if [ ! -d ${FilePathOnMachine} ]
then
  echo "Creo la directory ${FilePathInMachine}"
  mkdir -p ${FilePathOnMachine}
  progressivo=1
else
  progressivo=`find ${filePathInMachine} ${ProjectName}*.bnd | wc -l`
  progressivo++
fi
OUTPUT_FILE=${FilePathOnMachine}/${ProjectName}_${progressivo}.bnd
cat /dev/null > ${OUTPUT_FILE}

#***************************************************************
# Cerco il numero dei SER
#***************************************************************
NumeroSer=`cat ${SER_LIST} |wc -l`
if [ ${NumeroSer} = 0 ]
then
  echo "ERRORE: non ci sono ser nella lista ${SER_LIST}"
  exit 6
fi
 
#***************************************************************
# Creo il file di output con un ciclo per il numero dei dbrm
#***************************************************************
counter=0
while [ ${counter} -le ${NumeroSer} ]
do
  counter++
  DBRMName=`cat ${LIST_MACHINE_FILE} | head -n ${counter} | tail -n 1 | awk '{ print $3 }'`

  echo "BIND PACKAGE(?????) QUALIFIER(${QUALIFIER_DB2}) ACTION(REPLACE) -" >> ${OUTPUT_FILE}
  echo "MEMBER (${DBRMNAME}1) VALIDATE(BIND) ISOLATION(UR) -" >> ${OUTPUT_FILE}
  echo "CURRENTDATA (NO) OWNER(${OWNER_DB2}) -" >> ${OUTPUT_FILE}
  echo "RELEASE(COMMIT) ENABLE(*) EXPLAIN(NO)" >> ${OUTPUT_FILE}

  echo "BIND PACKAGE(?????) QUALIFIER($QUALIFIER_DB2}) ACTION(REPLACE) -" >> ${OUTPUT_FILE}
  echo "MEMBER (${DBRMNAME}2) VALIDATE(BIND) ISOLATION(CS) -" >> ${OUTPUT_FILE}
  echo "CURRENTDATA (NO) OWNER(${OWNER_DB2}) -" >> ${OUTPUT_FILE}
  echo "RELEASE(COMMIT) ENABLE(*) EXPLAIN(NO)" >> ${OUTPUT_FILE}

  echo "BIND PACKAGE(?????) QUALIFIER(${QUALIFIER_DB2}) ACTION(REPLACE) -" >> ${OUTPUT_FILE}
  echo "MEMBER (${DBRMNAME}3) VALIDATE(BIND) ISOLATION(RS) -" >> ${OUTPUT_FILE}
  echo "CURRENTDATA (NO) OWNER(${OWNER_DB2}) -" >> ${OUTPUT_FILE}
  echo "RELEASE(COMMIT) ENABLE(*) EXPLAIN(NO)" >> ${OUTPUT_FILE}

  echo "BIND PACKAGE(?????) QUALIFIER(${QUALIFIER_DB2}) ACTION(REPLACE) -" >> ${OUTPUT_FILE}
  echo "MEMBER (${DBRMNAME}4) VALIDATE(BIND) ISOLATION(RR) -" >> ${OUTPUT_FILE}
  echo "CURRENTDATA (NO) OWNER(${OWNER_DB2}) -" >> ${OUTPUT_FILE}
  echo "RELEASE(COMMIT) ENABLE(*) EXPLAIN(NO)" >> ${OUTPUT_FILE}
  
done

echo "Operazione terminata"