#!/bin/ksh

#####PATH DEI CENSIMENTI
RUN=/oradata/ITT0/app/spOrchSuite/bin/runtime
MF_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_MF/produzione
MF_C=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_MF/collaudo
MF_SP=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_MF/send/produzione
MF_SC=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_MF/send/collaudo
WORK=/oradata/ITT0/app/spOrchSuite/bin/runtime/WORK
BCK=/oradata/ITT0/app/spOrchSuite/bin/runtime/Send_Censimenti/bck
SEND=/oradata/ITT0/app/spOrchSuite/bin/runtime/Send_Censimenti
#################

cd $MF_P

mv *.*.* $MF_SP
