#!/bin/ksh

#######################################
# script per la acquisizione dei      #
# file da gibli	via SFTP			  #
# Autore: Giorgio Fratepietro         #
# Società:Primeur                     #
# Versione:1                          #
#######################################

###### SET ENVIRONMENT VARIABLES
unique_id=`echo $$`
export DATA=`date "+%Oy%m%Od"`

# SET INTERNAL VARIABLES

export USER=$1
export PASW=$2
export ELENCOFILE=$3
export hostremoto=172.27.131.81
export dirwork=/opt/ghibli/corner
export dirinput=/opt/ghibli/share/shared/temp/allineamento
#export dirlog=$dirwork/log
export dirlog=/opt/ghibli/share/logs
export dircfg=$dirwork/cfg
export dirbin=$dirwork/bin
export dirdone=$dirwork/done

#log

mainlog=$dirlog/Acquisitore_sftp_$USER\_$DATA.log
touch $mainlog
MISURA=500000
SIZE=$(ls -l $mainlog | awk '{print $5}')
if [ $SIZE -gt $MISURA ]
then
   mv $mainlog $mainlog.bak
   rm $mainlog.bak.gz
   gzip -9 $mainlog.bak
fi


#inizio
echo \[${unique_id}\] ====================START=$ELENCOFILE========================================================================= >> $mainlog
echo \[${unique_id}\] \[INFO\] `date "+%Od/%0m/%Oy %H:%M:%S"` - $*  >> $mainlog
echo \[${unique_id}\] \[INFO\] "verifico l'esistenza $ELENCOFILE" >> $mainlog
ls $ELENCOFILE
export rcls=$?
if [ $rcls -ne 0 ]
  then
                echo \[${unique_id}\] \[CRITICAL\] "non esiste il file $ELENCOFILE" >> $mainlog
                echo \[${unique_id}\] \[CRITICAL\] "RC:$rcls" >> $mainlog
                echo \[${unique_id}\] ====================END=KO=$rcls=$filename========================================================================= >> $mainlog
  exit 1
fi
echo \[${unique_id}\] \[INFO\] "l'elenco dei file da acquisire esiste"     >> $mainlog
echo \[${unique_id}\] \[INFO\] "inizio il ciclo di acquisizione dei file per lo user: $USER"     >> $mainlog
cd $dirwork/done
for FILE in `cat $ELENCOFILE `
do
	export FILEacq=$(echo $FILE|awk -F ";" '{print $2}'| sed 's/\"//g')
	echo \[${unique_id}\] \[INFO\] "acquisisco il file $FILE" >> $mainlog
  echo "get $FILEacq" | sshpass -p $PASW sftp -P 2622 $USER@$hostremoto 
	ls $dirwork/done/$FILEacq
	export rcls1=$?
	if [ $rcls1 -ne 0 ]
	then
                echo \[${unique_id}\] \[WARINIG\] "non scaricato il file $FILE" >> $mainlog
    else
				echo \[${unique_id}\] \[INFO\] "scaricato il file $FILE" >> $mainlog
	fi
done
echo \[${unique_id}\] \[INFO\] "ciclo di acquisizione dei file per lo user: $USER terminato"     >> $mainlog
echo \[${unique_id}\] \[INFO\] `date "+%Od/%0m/%Oy %H:%M:%S"` - $*  >> $mainlog
echo \[${unique_id}\] ====================END=OK=$ELENCOFILE========================================================================= >> $mainlog
exit 0
