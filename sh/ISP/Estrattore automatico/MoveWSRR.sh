#!/bin/ksh	

#####PATH 
WSRR_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/produzione
WSRR_SP=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/send/produzione
WSRR_C=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/collaudo
WSRR_SC=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/send/collaudo
########

for FILE in `ls $WSRR_P/*.* 2>>/dev/null/`
do
mv $FILE $WSRR_SP
done

for FILE in `ls $WSRR_C/*.* 2>>/dev/null/`
do
mv $FILE $WSRR_SC
done