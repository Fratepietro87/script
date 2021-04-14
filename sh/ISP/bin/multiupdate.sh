#!/bin/ksh

#######################################
# script per la crazione massiva      #
# censimenti IXP-FT per progetto BFD  #
# Autore: Giorgio Fratepietro         #
# Revisore: Martina Manfrin           #
# Società:Primeur                     #
# Versione:2                          #
#######################################

###### SET ENVIRONMENT VARIABLES 
unique_id=`echo $$`
export DATA=`date "+%Oy%m%Od"`

# SET INTERNAL VARIABLES 

inputfile=$1
export dirwork=$RUN/BFD
export dirinput=$dirwork/input
export dirlog=$dirwork/log
export dircfg=$dirwork/cfg
export dirbin=$dirwork/bin
export dircensp=$dirwork/censimenti_produzione
export dircenss=$dirwork/censimenti_system
export dirdone=$dirwork/done
export diresi=$dirwork/esistenti
export template=$dircfg/template.ini

#log

mainlog=$dirlog/multicreatore_$inputfile.log
touch $mainlog
MISURA=500000
SIZE=$(ls -l $mainlog | awk '{print $5}')
if [ $SIZE -gt $MISURA ]
then
   mv $mainlog $mainlog.bak
   rm $mainlog.bak.gz
   gzip -9 $mainlog.bak
fi


#letture file di input
echo \[${unique_id}\] ====================START=$filename========================================================================= >> $mainlog
echo \[${unique_id}\] \[INFO\] `date "+%Od/%0m/%Oy %H:%M:%S"` - $*  >> $mainlog
echo \[${unique_id}\] \[INFO\] "inizio la lettura del file $inputfile" >> $mainlog
echo \[${unique_id}\] \[INFO\] "estraggo i template dal wsrr" >> $mainlog
$dirbin/Estrazione.sh $inputfile
export rcex=$?
if [ $rcex -ne 0 ]
  then
		echo \[${unique_id}\] \[CRITICAL\] "Errore nell'estrazione dal WSRR" >> $mainlog
		echo \[${unique_id}\] \[CRITICAL\] "RC:$rcex" >> $mainlog
		echo \[${unique_id}\] ====================END=KO=$rcex=$filename========================================================================= >> $mainlog
  exit 1
fi
echo \[${unique_id}\] \[INFO\] "ho estratto i file dal wsrr "     >> $mainlog

while IFS=";" 
read ID_CENSIMENTO OPERAZIONE APPLICAZIONE TGT_DEST DESCRIZIONE DQH_ISTITUTO QDH_AREA QDH_MITT QDH_DEST QDH_DOM4 MITTENTE AMB_LOGICO_MITTENTE MOD_TRANS FILE_IN ACRONIMO_DEST AMB_LOGICO_DESTINATARIO MOD_ACQ TARGET_FILE TWS POST_ACQ
do
export CENSIMENTO=$OPERAZIONE\_$APPLICAZIONE\_$AMB_LOGICO_MITTENTE
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "CENSIMENTO=$CENSIMENTO                                " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "NUMERO=$ID_CENSIMENTO                                 " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "OPERAZIONE=$OPERAZIONE                                " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "APPLICAZIONE=$APPLICAZIONE                            " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "TGT_DEST=$TGT_DEST                                    " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "DESCRIZIONE=$DESCRIZIONE                              " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "DQH_ISTITUTO=$DQH_ISTITUTO                            " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "QDH_AREA=$QDH_AREA                                    " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "QDH_MITT=$QDH_MITT                                    " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "QDH_DEST=$QDH_DEST                                    " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "QDH_DOM4=$QDH_DOM4                                    " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "MITTENTE=$MITTENTE                                    " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "AMB_LOGICO_MITTENTE=$AMB_LOGICO_MITTENTE              " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "MOD_TRANS=$MOD_TRANS                                  " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "FILE_IN=$FILE_IN                                      " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "ACRONIMO_DEST=$ACRONIMO_DEST                          " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "AMB_LOGICO_DESTINATARIO=$AMB_LOGICO_DESTINATARIO      " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "MOD_ACQ=$MOD_ACQ                                      " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "TARGET_FILE=$TARGET_FILE                              " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "TWS=$TWS                                              " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "POST_ACQ=$POST_ACQ                                    " >> $mainlog

###Verifico l'univocità del binomio OPERAZIONE APPLICAZIONE all'interno dei censimenti estratti dal wsrr
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "verifico l'univocità del censimento $CENSIMENTO all'interno del wsrr" >> $mainlog
ls $diresi/$CENSIMENTO 1>>/dev/null 2>>/dev/null
export rclsesi=$?
case $rclsesi in 
	 "2")
			echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "non esiste il censimeto $CENSIMENTO nel wsrr"     >> $mainlog
	  ;;
	 "0")
			echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[ERROR\] "il censimento $ID_CENSIMENTO ha OPERAZIONE APPLICAZIONE e ABIENTE LOGICO già utilizzato all'interno del wsrr" >>$mainlog
			
	  ;;
	   *)
	  		echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[CRITICAL\] "ls ha tornato rc $rcls non gestito" >>$mainlog
			echo \[${unique_id}\] ====================END=KO=$rclsesi=$filename========================================================================= >> $mainlog
			exit 2
      ;;
esac

###Verifico l'univocità del binomio OPERAZIONE APPLICAZIONE all'interno della lista fornita tramite il file di input
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "verifico l'esistenza del censimento $OPERAZIONE\_$APPLICAZIONE\_$AMB_LOGICO_MITTENTE" >> $mainlog
ls $dircensp/$OPERAZIONE\_$APPLICAZIONE\_$AMB_LOGICO_MITTENTE 1>>/dev/null 2>>/dev/null
export rcls=$?
case $rcls in 
	 "2")
			echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "non esiste il censimeto $OPERAZIONE\_$APPLICAZIONE\_$AMB_LOGICO_MITTENTE in $dircensp"     >> $mainlog
			###Creo il templeta in cui andare a cabiare le varibili proprie del censimento che bisogna creare
			cp $template $dircensp/$CENSIMENTO
			export rccp=$?
			if [ $rccp -ne 0 ]
			  then
					echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[CRITICAL\] "Error nella copy $template $dircensp/$OPERAZIONE_$APPLICAZIONE_$AMB_LOGICO_MITTENTE" >> $mainlog
					echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[CRITICAL\] "RC:$rccp" >> $mainlog
					echo \[${unique_id}\] ====================END=KO=$rccp=$filename========================================================================= >> $mainlog
              exit 3
			fi
			echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "ho creato il file $CENSIMENTO in $dircensp "     >> $mainlog
	  ;;
	 "0")
			echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[ERROR\] "il censimento $ID_CENSIMENTO ha OPERAZIONE APPLICAZIONE e ABIENTE LOGICO già utilizzato all'interno del file di input" >>$mainlog
			
	  ;;
	   *)
	  		echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[CRITICAL\] "ls ha tornato rc $rcls non gestito" >>$mainlog
			echo \[${unique_id}\] ====================END=KO=$rcls=$filename========================================================================= >> $mainlog
			exit 4
      ;;
esac

###Dalla variabile MITTENTE ricavo il qm spazio di partenza
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "ricavo il qm dalla mittenza di produzione" >> $mainlog
export QMANAGER=$(cat "$dircfg/schema_qmanager.ini" | grep -E "$MITTENTE" | sed 's/\s//g' | cut -f2 -d\;)
if [ ${#QMANAGER} -le 0 ] 
  then
		echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[ERROR\] "Non è censito un QM per la mitenza $MITTENTE" >> $mainlog
		continue
fi
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "QMANAGER=$QMANAGER                                    " >> $mainlog

###Ricavo dalla viariabile SO di destinazione il path di destinazione
export TGTPATH=$(grep "$AMB_LOGICO_DESTINATARIO" $dircfg/ambiente_dest.ini | awk '{print $2}')
if [ ${#TGTPATH} -le 0 ] 
  then
		echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[ERROR\] "Non è censito un Terget Path per la destinazione $AMB_LOGICO_DESTINATARIO" >> $mainlog
		continue
fi

###Ricavo il processo da lancaire a destinazione
if [ ${#TWS} -gt 0 ] 
  then
		echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "A destinazione è statato chiesto di lanciare la tws $TWS" >> $mainlog
		export LANCIO=APPLIDTWS\=$TWS
		###recupero il TGT_MODEL dal censimento
		export TGT_MODEL=$(grep MODEL $template)
		echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "inserisco il lancio della tws a destinazione" >> $mainlog
		echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/$TGT_MODEL/$TGT_MODEL\ $LANCIO/g' $dircensp/$CENSIMENTO" >> $mainlog
		perl -pi -e 's/'"$TGT_MODEL"'/'"$TGT_MODEL"'\ '"$LANCIO"'/g' $dircensp/$CENSIMENTO
elif [ ${#TWS} -le 0 ]
  then 
     if [ ${#POST_ACQ} -gt 0 ] 
       then
		   echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "A destinazione è statato chiesto di lanciare lo script $POST_ACQ" >> $mainlog
		   export LANCIO=PGMDEST\=$POST_ACQ
		   ###recupero il TGT_MODEL dal censimento
		   export TGT_MODEL=$(grep MODEL $template)
		   echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "inserisco il lancio dello script di post'acquisizione" >> $mainlog
		   echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/$TGT_MODEL/$TGT_MODEL\ $LANCIO/g' $dircensp/$CENSIMENTO" >> $mainlog
		   perl -pi -e 's/'"$TGT_MODEL"'/'"$TGT_MODEL"'\ '"$LANCIO"'/g' $dircensp/$CENSIMENTO
		   export PROG=\*PARAMS
		   ###recupero il PGMDEST dal censimento
		   export PGMDEST=$(grep "CTL_PGM_DEST\ =" $template)
		   echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "inserisco *PARAMS nel PGM_DEST" >> $mainlog
		   echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/$PGMDEST/$PGMDEST\ $PROG/g' $dircensp/$CENSIMENTO" >> $mainlog
		   perl -pi -e 's/'"$PGMDEST"'/'"$PGMDEST"'\ '"$PROG"'/g' $dircensp/$CENSIMENTO
		   ###recupero la proc dal SO di destinazione
		   export PROC=$(grep "$AMB_LOGICO_DESTINATARIO" $dircfg/ambiente_dest.ini | awk '{print $3}')
		   if [ ${#PROC} -le 0 ] 
             then
		   echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[ERROR\] "Non è censito una proc per la destinazione $AMB_LOGICO_DESTINATARIO" >> $mainlog
		   continue
           fi
		   ###recupero la PROC_DEST dal censimento
		   export PROCDEST=$(grep "DIR_PROC" $template)
		   echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "inserisco $PROC nel PROCDEST" >> $mainlog
		   echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/$PROCDEST/$PROCDEST\ $PROC/g' $dircensp/$CENSIMENTO" >> $mainlog
		   perl -pi -e 's/'"$PROCDEST"'/'"$PROCDEST"'\ '"$PROC"'/g' $dircensp/$CENSIMENTO
	 elif [ ${#POST_ACQ} -le 0 ]
       then
           echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "non è stato richiesto il lancio di post'acquisitori per il cesimenti N $ID_CENSIMENTO" >> $mainlog   
     fi
fi

###Guardo se parte dal mondo Target e gestisco il FILE_IN
if [ $MITTENTE = ACRONIMO ]
	then
		echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "La mittenza è un acronimo Target" >> $mainlog
		export FILEIN=" FILEIN\=$FILE_IN"
		export TGT_MODEL=$(grep MODEL $template)
		echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "inserisco il lancio dello script di post'acquisizione" >> $mainlog
		echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/$TGT_MODEL/$TGT_MODEL\ $FILEIN/g' $dircensp/$CENSIMENTO" >> $mainlog
		perl -pi -e 's/'"$TGT_MODEL"'/'"$TGT_MODEL"'\'"$FILEIN"'/g' $dircensp/$CENSIMENTO
fi

###Sostituzione delle varibili ricavate all'interno del template $OPERAZIONE\_$APPLICAZIONE\_$AMB_LOGICO_MITTENTE
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "inizio sostituzione campi nel template" >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/OPPPEEERRR/$OPERAZIONE/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/OPPPEEERRR/'"$OPERAZIONE"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/APPLLIIC/$APPLICAZIONE/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/APPLLIIC/'"$APPLICAZIONE"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/AMBLOGICMITTTT/$AMB_LOGICO_MITTENTE/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/AMBLOGICMITTTT/'"$AMB_LOGICO_MITTENTE"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/DESCRIZZ/$DESCRIZIONE/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/DESCRIZZ/'"$DESCRIZIONE"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/TGTDESTTT/$TGT_DEST/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/TGTDESTTT/'"$TGT_DEST"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/ACRRRODE/$ACRONIMO/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/ACRRRODE/'"$ACRONIMO_DEST"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/MODACQQQQQ/$MOD_ACQ/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/MODACQQQQQ/'"$MOD_ACQ"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/MODTRANSSSS/$MOD_TRANS/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/MODTRANSSSS/'"$MOD_TRANS"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/QDHARRREA/$QDH_AREA/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/QDHARRREA/'"$QDH_AREA"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/QDHDESTT/$QDH_DEST/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/QDHDESTT/'"$QDH_DEST"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/QDHDOM4444/$QDH_DOM4/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/QDHDOM4444/'"$QDH_DOM4"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/QDHISITTT/$DQH_ISTITUTO/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/QDHISITTT/'"$DQH_ISTITUTO"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/QDHMITTT/$QDH_MITT/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/QDHMITTT/'"$QDH_MITT"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/QMANAAA/$QMANAGER/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/QMANAAA/'"$QMANAGER"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/TGTFILLLE/$TARGET_FILE/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/TGTFILLLE/'"$TARGET_FILE"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/TGTPATTHH/$TGTPATH/g' $dircensp/$CENSIMENTO" >> $mainlog
perl -pi -e 's/TGTPATTHH/'"$TGTPATH"'/g' $dircensp/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "fine sostituzione campi nel template" >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "censimento $CENSIMENTO pronto per il caricamento in produzione" >> $mainlog

##creo il ensimento da caricare in ambiente di system test
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "creo il template da creare in system del censimento $CENSIMENTO in $dircenss "     >> $mainlog
cp $dircensp/$CENSIMENTO $dircenss/$CENSIMENTO
export rccp=$?
if [ $rccp -ne 0 ]
  then
		echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[CRITICAL\] "Error nella copy $template $dircensp/$CENSIMENTO $dircenss/$CENSIMENTO" >> $mainlog
		echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[CRITICAL\] "RC:$rccp" >> $mainlog
		echo \[${unique_id}\] ====================END=KO=$rccp=$filename========================================================================= >> $mainlog
  exit 5
fi
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "ho creato il file $CENSIMENTO in $dircenss "     >> $mainlog

###Sostituzione delle varibili ricavate all'interno del template per il system test
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "ricavo il QM di system test "     >> $mainlog
export QMANAGERS=$(cat "$dircfg/schema_qmanager.ini" | grep -E "$MITTENTE" | sed 's/\s//g' | cut -f3 -d\;)
if [ ${#QMANAGERS} -le 0 ] 
  then
		echo \[${unique_id}\] \["$ID_CENSIMENTO"] \[ERROR\] "Non è censito un QM per la mitenza $MITTENTE in ambiente di system test" >> $mainlog
		rm $dircenss/$CENSIMENTO
		continue
fi
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "QMANAGER SYSTEM=$QMANAGERS                                    " >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "inizio sostituzione campi nel template di system test" >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/$QMANAGER/$QMANAGERS/g' $dircenss/$CENSIMENTO" >> $mainlog
perl -pi -e 's/'"$QMANAGER"'/'"$QMANAGERS"'/g' $dircenss/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "perl -pi -e 's/UD0/UDD/g' $dircenss/$CENSIMENTO" >> $mainlog
perl -pi -e 's/UD0/UDD/g' $dircenss/$CENSIMENTO
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "fine sostituzione campi nel template di system test" >> $mainlog
echo \[${unique_id}\]  \["$ID_CENSIMENTO"] \[INFO\] "censimento $CENSIMENTO pronto per il caricamento in system" >> $mainlog

done < $dirinput/$inputfile


echo \[${unique_id}\] ====================END=OK=$filename========================================================================= >> $mainlog
exit 0
