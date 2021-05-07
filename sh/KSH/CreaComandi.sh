#***************************************************************
#* 			CreaComandi.sh
#*
#* Goal: creare un file di comandi per ogni macchina 
#*
#* Parameters: $1 Nome del progetto
#*             $2 File Ear (Comprensivo di Path)
#*             $3 File DBRM (Comprensivo di Path)
#*
#* Author: Luca Brizzolara, Selesta
#* Date: July 2004 
#***************************************************************

if test -n $1 -a -n $2 - a $3
then
  ProjectName=$1
  EAR_FILE=$2
  DBRM_FILE=$3
else
  echo "ERRORE nel lancio della script."
  echo "Usage: CreaComandi.sh Nome_del_progetto file_ear_con_path file_dbrm_con_path"
  exit 1
fi

#***************************************************************
# Controllo l'esistenza e leggibilità del file EAR
#***************************************************************
if [ ! -r $EAR_FILE ]
then
  echo "Manca il file $EAR_FILE o non ci sono i permessi di lettura"
  exit 2
fi

#***************************************************************
# Controllo l'esistenza e leggibilità del file DBRM
#***************************************************************
if [ ! -r $DBRM_FILE ]
then
  echo "Manca il file $DBRM_FILE o non ci sono i permessi di lettura"
  exit 3
fi

#***************************************************************
# Definisco il nome del file con l'elenco delle macchine
#***************************************************************
LIST_MACHINE_PATH=???
LIST_MACHINE_NAME=machine_list.txt
LIST_MACHINE_FILE=$LIST_MACHINE_PATH/$LIST_MACHINE_NAME

#***************************************************************
# Controllo l'esistenza del file con la lista dei parametri per ogni macchina
#***************************************************************
if [ ! -r $LIST_MACHINE_FILE ]
then
  echo "Manca il file $LIST_MACHINE_FILE o non ci sono i peressi di lettura"
  exit 4
else
  NumeroMacchine=`cat $LIST_MACHINE_FILE |wc -l`
fi

#***************************************************************
# Definisco il nome del file con i dati del progetto
#***************************************************************
PROJECT_FILE_PATH=??
PROJECT_FILE_NAME=$ProjectName.lst
FILE_PROJECT=$LPROJECT_FILE_PATH/$PROJECT_FILE_NAME

#***************************************************************
# Controllo l'esistenza del file con la lista dei parametri per ogni macchina
#***************************************************************
if [ ! -r $FILE_PROJECT ]
then
  echo "Manca il file $FILE_PROJECT o non ci sono i permessi di lettura"
  exit 5
else
  APPL_SUFFIX=`cat $FILE_PROJECT |awk -F: '{ print $2 }'`
  DB2_DATASOURCE_NAME=`cat $FILE_PROJECT |awk -F: '{ print $3 }'`
  CICS_DATASOURCE_NAME=`cat $FILE_PROJECT |awk -F: '{ print $4 }'`
  SYSTEM_DB2=`cat $FILE_PROJECT |awk -F: '{ print $5 }'`
  DB2_QUALIFIER=`cat $FILE_PROJECT |awk -F: '{ print $6 }'`
  DB2_OWNER=`cat $FILE_PROJECT |awk -F: '{ print $7 }'`
fi

#***************************************************************
# Controllo che ci siano macchine definite
#***************************************************************
if [ $NumeroMacchine < 1 ]
then
  echo "Non ci sono macchine per cui creare i file di comandi"
  exit 6
fi

counter=0
while [ $counter -le $NumeroMacchine ]
do
  counter++
  MachineName=`cat $LIST_MACHINE_FILE |head -n $counter |tail -n 1 | awk -F: '{ print $1 }'`
  FilePathOnMachine=`cat $LIST_MACHINE_FILE |head -n $counter |tail -n 1 | awk -F: '{ print $2 }'`
  MachineApplServerPrefix=`cat $LIST_MACHINE_FILE |head -n $counter |tail -n 1 | awk -F: '{ print $3 }'`
  if [ ! -d $FilePathOnMachine ] 
  then
    echo "Creo la directory $FilePathInMachine"
    mkdir -p $FilePathOnMachine
    progressivo=1
  else
    progressivo=`find $filePathInMachine $ProjectName*.cmd | wc -l`
    progressivo++
  fi
  OUTPUT_FILE=$FilePathOnMachine/$ProjectName_$progressivo
  echo "$ProjectName:$MachineApplServerPrefix$APPL_SUFFIX:$EARFILE:$DBRM_FILE:$DB2_DATASOURCE_NAME:$CICS_DATASOURCE_NAME" > $OUTPUT_FILE
done

echo "Operazione terminata"