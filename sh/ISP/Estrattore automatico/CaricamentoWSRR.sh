#!/bin/ksh	

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

####CARICAMENTO CENSIMENTI IN PRODUZIONE

##INIZIO CARICAMENTO
for FILE in `ls $WSRR_SP/*.*`
do
  CENS=`basename $FILE`
  $VIRTUAL_DRIVE/WSSRLoader/Loader.sh  $VIRTUAL_DRIVE "-server=ixpwsrrconsole.bancaintesa.it" "-port=9081" "-operation=I1"  "-fileTemplate=$WSRR_SP/$CENS" > $PATHLOG/$CENS.log

mv $WSRR_SP/$CENS $PATHBCK
## FINE CARIMENTO PRODUZIONE