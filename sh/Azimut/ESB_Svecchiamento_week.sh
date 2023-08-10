#!/usr/bin/bash
# =======================================================================================================================
# ESB - Procedura svecchiamento File
# versione = 2.0.5
#
# Ver 2.0 Autore   = Giorgio Antonio Fratepietro
# Società  = Primeur
#
# Ver 2.0.5
# from : DI RESTA COSTANTINO
# Società = Avangard Counsulting
# - add BASENAME Parsed DIR to logfile
# - add -(f)orce flag to gzip to exclude Confir Prompt during execution restart
 
#=======================================================================================================================

###### SET ENVIRONMENT VARIABLES
unique_id=`echo $$`
export unique_id
BASE_DIR=$1
export BASE_DIR
DATA=`date "+%Oy%m%Od"`
export DATA
##numero di giorni da cui partire con lo svecchiamento
DEEP=$2
export DEEP


BASE_NAME_DIR=`basename $BASE_DIR`
export BASE_NAME_DIR
#### #SET LOG FILE AND SIZEING

logfile=/esb_archive/log/Svecchia_ESB.$BASE_NAME_DIR"_"$DATA.log


export logfile

echo  "log file: "$logfile
echo " basename: "$BASE_NAME_DIR


##### INIZIO ESECUZIONE EFFETTIVA DELLO SCRIPT

echo \[${unique_id}\] ====================START=ESB_Svecchiamento========================================================================= >> $logfile
echo \[${unique_id}\] \[INFO\] `date "+%Od/%0m/%Oy %H:%M:%S"` - $*  >> $logfile
echo \[${unique_id}\] \[INFO\] "workdir=$BASE_DIR"               >> $logfile
echo \[${unique_id}\] \[INFO\] "N gg=$DEEP"       >> $logfile
echo \[${unique_id}\] \[INFO\] "verifico le directory da svecchiare"       >> $logfile
echo \[${unique_id}\] \[INFO\] "inizio il ciclo delle directory da svecchiare"       >> $logfile
N_OLDER=0
export N_OLDER
N_OLDOK=0
export N_OLDOK
N_DIR=`ls -l $BASE_DIR/| grep ^d | awk '{print $9}'| wc -l`
export N_DIR
for DIR in `ls -l $BASE_DIR/| grep ^d | awk '{print $9}'`
	do
	echo \[${unique_id}\] \[INFO\] "lavoro sulla directory $DIR"       >> $logfile
	##### inserire le logiche che si vogliono adottare per ogni directory in cui sono presenti i file dell'ESB
	find $BASE_DIR/$DIR -mtime +$DEEP -type f ! -name '*.gz' -exec gzip -rf {} \;	
	rcgzip=$?
	if [ $rcgzip -ne 0 ]
		then
		echo \[${unique_id}\] \[$TIMESTAMPP\] \[WARNING\] "la zip per la directory $DIR è andata male " >> $logfile
		echo \[${unique_id}\] \[$TIMESTAMPP\] \[WARNING\] "RC:$rcgzip" >> $logfile
		N_OLDER=`expr $N_OLDER + 1`
		export N_OLDER
		continue
		else
		echo \[${unique_id}\] \[INFO\] "la zip per la directory $DIR è andata bene"       >> $logfile
		N_OLDOK=`expr $N_OLDOK + 1`
		export N_OLDOK
	fi
	done
N_CICL=`expr $N_OLDOK + $N_OLDER`
export N_CICL
if [ $N_OLDOK = $N_DIR ] && [ $N_OLDER = 0 ]
	then 
	echo \[${unique_id}\] \[INFO\] "tutte le directort sono state ciclate"       >> $logfile
	echo \[${unique_id}\] \[INFO\] "ho verificato $N_OLDOK directory"       >> $logfile
	echo \[${unique_id}\] ====================END=ESB_Svecchiamento========================================================================= >> $logfile
	exit 0
	else
	if [ $N_CICL = $NDIR ]
		then
		echo \[${unique_id}\] \[WARNING\] "verificare il ciclo di esecuzione poichè è presente la seguente situazione" >> $logfile
		echo \[${unique_id}\] \[WARNING\] "Directory da verificare = $N_DIR" >> $logfile
		echo \[${unique_id}\] \[WARNING\] "Directory verificate OK = $N_OLDOK" >> $logfile
		echo \[${unique_id}\] \[WARNING\] "Directory verificate KO = $N_OLDER" >> $logfile
		else
		if [ $N_CICL != $NDIR ]
			then
			echo \[${unique_id}\] \[ERROR\] "verificare il file cfg poichè è presente la seguente situazione" >> $logfile
			echo \[${unique_id}\] \[ERROR\] "Directory da verificare = $N_DIR" >> $logfile
			echo \[${unique_id}\] \[ERROR\] "Directory verificate OK = $N_OLDOK" >> $logfile
			echo \[${unique_id}\] \[ERROR\] "Directory verificate KO = $N_OLDER" >> $logfile
			echo \[${unique_id}\] ====================END=ESB_Svecchiamento========================================================================= >> $logfile
			exit 2
			else
			echo \[${unique_id}\] \[ERROR\] "verificare il ciclo di esecuzione poichè è presente la seguente situazione" >> $logfile
			echo \[${unique_id}\] \[ERROR\] "Directory da verificare = $N_DIR" >> $logfile
			echo \[${unique_id}\] \[ERROR\] "Directory verificate OK = $N_OLDOK" >> $logfile
			echo \[${unique_id}\] \[ERROR\] "Directory verificate KO = $N_OLDER" >> $logfile
			echo \[${unique_id}\] ====================END=ESB_Svecchiamento========================================================================= >> $logfile
			exit 3
		fi
	fi
fi

