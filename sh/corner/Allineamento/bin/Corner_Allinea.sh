#!/bin/ksh
#######################################
# script per la verifica e 	      #
# l'acquisizione dei file da gibli    #	
#  e relativa cancellazione via SFTP  #
# Autore: Giorgio Fratepietro         #
# Società:Primeur                     #
# Versione:1                          #
#######################################

###### SET ENVIRONMENT VARIABLES
unique_id=`echo $$`
export DATA=`date "+%Oy%m%Od"`

# SET INTERNAL VARIABLES

export dirwork=/home/primeur/corner/
#export dirinput=$dirwork/input
export dirinput=$dirwork/input
export dirlog=$dirwork/log
export dircfg=$dirwork/cfg
export dirbin=$dirwork/bin
export dirdone=$dirwork/done

#log

mainlog=$dirlog/Corner_Allinea\_$DATA.log
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
echo \[${unique_id}\] ====================START=$DATA========================================================================= >> $mainlog
echo \[${unique_id}\] \[INFO\] `date "+%Od/%0m/%Oy %H:%M:%S"` - $*  >> $mainlog
echo \[${unique_id}\] \[INFO\] verifico la presenza dei file da dover acquisire >> $mainlog
export NFILEVERI=$(ls $dirinput | wc -l)
if [ $NFILEVERI == 0 ]
then
	echo \[${unique_id}\] \[INFO\] non sono presenti file da processare in $dirinput >> $mainlog
	echo \[${unique_id}\] ====================END=OK=$DATA========================================================================= >> $mainlog
	exit 0
fi
echo \[${unique_id}\] \[INFO\] ci sono $NFILEVERI da dover processare >> $mainlog
for VFILE in `ls $dirinput/`
do
	echo \[${unique_id}\] \[INFO\] verifico la presenza di file letti oggi in $VFILE >> $mainlog
	grep $VFILE $dircfg/Utenze.csv
	export rccred=$?
	if [ $rccred -ne 0 ]
	then
			echo \[${unique_id}\] \[CRITICAL\] "non esiste la coda $VFILE nel file Utenze.csv" >> $mainlog
			echo \[${unique_id}\] \[CRITICAL\] "RC:$rccred" >> $mainlog
			continue
	fi
	echo \[${unique_id}\] \[INFO\] "la coda $VFILE è censita" >>$mainlog
	export userSFTP=$(grep $VFILE $dircfg/Utenze.csv | awk -F ',' '{ print $2 }')
	export pswSFTP=$(grep $VFILE $dircfg/Utenze.csv | awk -F ',' '{ print $3 }')
	echo \[${unique_id}\] \[INFO\] "credenziali: USER=$userSFTP e PSW=$pswSFTP" >>$mainlog
	echo \[${unique_id}\] \[INFO\] "lancio l'acquisizione dei file da Ghibli" >>$mainlog
	$dirbin/Corner_removeGhibli.sh $userSFTP $pswSFTP $dirinput/$TODAY\_$VFILE
	export rcCodaOggiGet=$?
	if [ $rcCodaOggiGet -ne 0 ]
	then
			echo \[${unique_id}\] \[CRITICAL\] "verificare la rm per la coda $VFILE" >> $mainlog
			echo \[${unique_id}\] \[CRITICAL\] "RC:$rcCodaOggiGet" >> $mainlog
			continue
	fi
	echo \[${unique_id}\] \[INFO\] "rm per la coda $VFILE per i file di $DATA terminata correttamente" >>$mainlog
	rm $dirinput/$TODAY\_$VFILE
	rm $dirinput/$VFILE
done
echo \[${unique_id}\] \[INFO\] "rm per i file di $DATA terminata correttamente" >>$mainlog
echo \[${unique_id}\] ====================END=OK=$DATA========================================================================= >> $mainlog
exit 0
