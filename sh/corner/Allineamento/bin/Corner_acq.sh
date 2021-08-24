#!/bin/ksh
#######################################
# script per la verifica e 			  #
# l'acquisizione dei file da gibli	  #	
# via SFTP							  #
# Autore: Giorgio Fratepietro         #
# Società:Primeur                     #
# Versione:1                          #
#######################################

###### SET ENVIRONMENT VARIABLES
unique_id=`echo $$`
export DATA=`date "+%Oy%m%Od"`

# SET INTERNAL VARIABLES

export dirwork=/opt/ghibli/corner
#export dirinput=$dirwork/input
export dirinput=/opt/ghibli/share/shared/temp/allineamento
#export dirlog=$dirwork/log
export dirlog=/opt/ghibli/share/logs
export dircfg=$dirwork/cfg
export dirbin=$dirwork/bin
export dirdone=$dirwork/done
export TODAY=`date "+%Y%m%d"`
export YESTERDAY=`TZ=MYT+24 date "+%Y%m%d"`
export ORARIO=130000
#log

mainlog=$dirlog/Corner_acq\_$DATA.log
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
	grep $TODAY $dirinput/$VFILE >/dev/null
	export greprc=$?
	grep $YESTERDAY $dirinput/$VFILE >/dev/null
	export grepyd=$?
	export RCTOTALE=$(($greprc+$grepyd))
	case $RCTOTALE in
         "2")
                        echo \[${unique_id}\] \[WARNING\] "non sono presenti file del $TODAY in $VFILE"     >> $mainlog
						echo \[${unique_id}\] \[INFO\] "get per la coda $VFILE per i file di $DATA terminata correttamente" >>$mainlog
						rm $dirinput/$TODAY\_$VFILE
						rm $dirinput/$VFILE
          ;;
         1|0)
                        echo \[${unique_id}\] \[INFO\] "sono presenti file da acquisire in data $TODAY e/o $YESTERDAY in $VFILE" >>$mainlog
						echo \[${unique_id}\] \[INFO\] "creo l'elenco dei file da acquisire tra le 13.00 di $YESTERDAY alle 12.59 di $TODAY " >>$mainlog
						grep $TODAY $dirinput/$VFILE | awk -v "confronto=$ORARIO" -F ";" '{if ($4 < confronto) print $0}' > $dirinput/$TODAY\_$VFILE
						grep $YESTERDAY $dirinput/$VFILE | awk -v "confronto=$ORARIO" -F ";" '{if ($4 >= confronto) print $0}' >> $dirinput/$TODAY\_$VFILE
                                                SIZEVFILE=$(ls -l $dirinput/$TODAY\_$VFILE | awk '{print $5}')
						echo \[${unique_id}\] \[INFO\] "SIZEVFILE=$SIZEVFILE" >>$mainlog
                                                        if [ $SIZEVFILE == 0 ]
                                                        then
                                                                echo \[${unique_id}\] \[INFO\] "non ci sono file da leggere nel range orario desiderato" >>$mainlog
                                                                rm $dirinput/$TODAY\_$VFILE
                                                                continue
                                                        fi
                                                echo \[${unique_id}\] \[INFO\] "ricavo user e password dal file di conf" >>$mainlog
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
						$dirbin/Corner_getGhibli.sh $userSFTP $pswSFTP $dirinput/$TODAY\_$VFILE
						export rcCodaOggiGet=$?
						if [ $rcCodaOggiGet -ne 0 ]
						then
								echo \[${unique_id}\] \[CRITICAL\] "verificare la get per la coda $VFILE" >> $mainlog
								echo \[${unique_id}\] \[CRITICAL\] "RC:$rcCodaOggiGet" >> $mainlog
								continue
						fi
                        echo \[${unique_id}\] \[INFO\] "get per la coda $VFILE per i file di $DATA terminata correttamente" >>$mainlog
						rm $dirinput/$TODAY\_$VFILE
						rm $dirinput/$VFILE
          ;;
           *)
                        echo \[${unique_id}\] \[CRITICAL\] "verificare le date nel file $VFILE" >>$mainlog
                        continue
      ;;
	esac
done
echo \[${unique_id}\] \[INFO\] "get per i file di $DATA terminata correttamente" >>$mainlog
echo \[${unique_id}\] ====================END=OK=$DATA========================================================================= >> $mainlog
exit 0
