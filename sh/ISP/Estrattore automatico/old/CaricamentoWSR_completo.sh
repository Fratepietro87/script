#!/bin/ksh	

##########################################
# script per caricamento tramite TWS dei #
# censimenti IXP-FT sul WSRR.            #
# Gia predisposto per riconoscere e      #
# caricare i censimenti anche sul WSRR   #
# di collaudo.                           #
##########################################

#####PATH 
RUN=/oradata/ITT0/app/spOrchSuite/bin/runtime
WSRR_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/produzione
WSRR_SP=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/send/produzione
WSRR_C=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/collaudo
WSRR_SC=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/send/collaudo
WORK=/oradata/ITT0/app/spOrchSuite/bin/runtime/WORK
INSTALLPATH=$ORSU/bin/runtime/Send_Censimenti/WSRR
VIRTUAL_DRIVE=$INSTALLPATH/java1.4
PATHLOG=$ORSU/bin/runtime/Send_Censimenti/log
PATHBCK=$ORSU/bin/runtime/Send_Censimenti/bck

###################

##COPIO I CENSIMENTI DA CARICARE IN COLLAUDO###
#cd $WSRR_P
#
#	for FILE in `grep OSPO * |awk -F ':' '{ print $1 }'`
#do
#cp $FILE $WSRR_C
#cd $WSRR_C
#perl -pi -e 's/CFT\_TGT\_FILE\=DOP0/CFT\_TGT\_FILE\=SDS\.DOP0/g' $FILE
#perl -pi -e 's/CFT\_TGT\_FILE\=DGP0/CFT\_TGT\_FILE\=SDS\.DGP0/g' $FILE
#cd -
#done
#    
#	for FILE in `grep MXED * |awk -F ':' '{ print $1 }'`
#do
#cp $FILE $WSRR_C
#cd $WSRR_C
#perl -pi -e 's/CFT\_TGT\_FILE\=DSPX/CFT\_TGT\_FILE\=SDX\.DSPX/g' $FILE
#cd -
#done
#
#    for FILE in `grep OOQ * |awk -F ':' '{ print $1 }'`
#do
#cp $FILE $WSRR_C
#done


####CARICAMENTO CENSIMENTI IN PRODUZIONE

##INIZIO CARICAMENTO

for FILE in `ls $WSRR_SP/*.*`
do
  CENS=`basename $FILE`
  $VIRTUAL_DRIVE/WSSRLoader/Loader.sh  $VIRTUAL_DRIVE "-server=ixpwsrrconsole.bancaintesa.it" "-port=9081" "-operation=I1"  "-fileTemplate=$WSRR_P/$CENS" > $PATHLOG/$CENS.log

mv $WSRR_SP/$CENS $PATHBCK

## FINE CARIMENTO PRODUZIONE

####CARICAMENTO CENSIMENTI IN COLLAUDO
#
##FILE DI LOG
#LOGC=$WSRR_C/log/Caricamenti$(date '+%Y-%m-%d_%H:%M:%S')Col.log
#Log() {
#echo $(date '+%Y-%m-%d %H:%M:%S') \| $1 \| $$ \| TH$2 \| "$3" >> $LOGC
#}
#
#SleepTime=5
#
###INIZIO CARICAMENTO
#
#for FILE in `ls $WSRR_C/*.*`
#do
#
#  CENS=`basename $FILE`
#   $VIRTUAL_DRIVE/WSSRLoader/Loader.sh  $VIRTUAL_DRIVE "-server=ixpwebservices-col.bancaintesa.it" "-port=9081" "-operation=I1"  "-fileTemplate=$WSRR_SC/$CENS" > $PATHLOG/$CENS.log
#
#mv $WSRR_SC/$CENS $PATHBCK
#
#
#  grep "presente nel Registry" /oradata/ITT0/app/spOrchSuite/bin/runtime/Send_Censimenti/log/$CENS.log 1>/dev/null 2>&1
#  rc=$?
#
#  if [ $rc -eq 0 ] ; then
#     Log WARNING 0005W "Censimento $CENS gia Presente"
#     sleep $SleepTime
#     continue
#  fi
#
#  grep "Totale censimenti inseriti = 1" /oradata/ITT0/app/spOrchSuite/bin/runtime/Send_Censimenti/log/$CENS.log 1>/dev/null 2>&1
#  rc=$?
#
#  if [ $rc -eq 0 ] ; then
#     Log OK 0000K "Caricamento Effettuato Correttamente $FILE"
#  elif [ $rc -eq 1 ] ; then
#     Log ERROR 00015E "Errore nel Caricamento $FILE"
#  elif [ $rc -eq 2 ] ; then
#     Log ERROR 00045E "File di Log non Generato"
#  else
#     Log FATAL 00111F "Error Unexpected"
#  fi
#
#  sleep $SleepTime
#
#done
#
#
#
##FINE CARICAMENTO COLLAUDO
