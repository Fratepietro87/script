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
export dircens=$dirwork/censimenti
export dirdone=$dirwork/done
export diresi=$dirwork/esistenti
export template=$dircfg/template.ini

#log

mainlog=$dirlog/estrazione_$inputfile.log
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
echo \[${unique_id}\] \[INFO\] "inizio del processo di creazione" >> $mainlog
echo \[${unique_id}\] \[INFO\] "pulisco il file $dircfg/DaEstrarre" >> $mainlog
rm $dircfg/DaEstrarre

###creo i file per l'estrazione dal WSRR
echo \[${unique_id}\] \[INFO\] "inizio la lettura del file $inputfile" >> $mainlog
while IFS=";" 
read ID_CENSIMENTO OPERAZIONE APPLICAZIONE TGT_DEST DESCRIZIONE DQH_ISTITUTO QDH_AREA QDH_MITT QDH_DEST QDH_DOM4 MITTENTE AMB_LOGICO_MITTENTE MOD_TRANS ACRONIMO_DEST AMB_LOGICO_DESTINATARIO MOD_ACQ TARGET_FILE TWS POST_ACQ
do
export CENSIMENTO=$OPERAZIONE\_$APPLICAZIONE\_$AMB_LOGICO_MITTENTE
echo \[${unique_id}\] \[INFO\] "CENSIMENTO=$CENSIMENTO                                " >> $mainlog
echo \[${unique_id}\] \[INFO\] "NUMERO=$ID_CENSIMENTO                                 " >> $mainlog
echo \[${unique_id}\] \[INFO\] "OPERAZIONE=$OPERAZIONE                                " >> $mainlog
echo \[${unique_id}\] \[INFO\] "APPLICAZIONE=$APPLICAZIONE                            " >> $mainlog
echo \[${unique_id}\] \[INFO\] "TGT_DEST=$TGT_DEST                                    " >> $mainlog
echo \[${unique_id}\] \[INFO\] "preparo i file per l'estrazione						  " >> $mainlog
export CERCARE=$OPERAZIONE\_$APPLICAZIONE\_$AMB_LOGICO_MITTENTE=$OPERAZIONE\_$TGT_DEST\_$AMB_LOGICO_MITTENTE
echo "$CERCARE" >> $dircfg/DaEstrarre
done < $dirinput/$inputfile

###estraggo i file dal wsrr
echo \[${unique_id}\] \[INFO\] "estraggo i file dal wsrr							  " >> $mainlog
$dirbin/Extractor_Prod.sh 
export rcex=$?
if [ $rcex -ne 0 ]
  then
		echo \[${unique_id}\] \[CRITICAL\] "Errore nell'estrazione dal WSRR" >> $mainlog
		echo \[${unique_id}\] \[CRITICAL\] "RC:$rcex" >> $mainlog
		echo \[${unique_id}\] ====================END=KO=$rcex=$filename========================================================================= >> $mainlog
  exit 1
fi
echo \[${unique_id}\] \[INFO\] "ho estratto i file dal wsrr "     >> $mainlog