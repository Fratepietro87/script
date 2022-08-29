#!/bin/ksh


Log() {
echo $(date '+%Y-%m-%d %H:%M:%S') \| $1 \| $$ \| TH$2 \| "$3" >> $WSRR_P/log/Caricamenti$(date '+%Y-%m-%d %H:%M:%S').log
}

SleepTime=5

cd $RUN/WSRR

for FILE in `ls WSRR_P`
do

  CENS=`basename $FILE`
  Aclient_Produzione.sh $CENS 2>/dev/null

  grep "presente nel Registry" /oradata/ITT0/app/spOrchSuite/bin/runtime/Send_Censimenti/log/$CENS.log 1>/dev/null 2>&1
  rc=$?

  if [ $rc -eq 0 ] ; then
     Log WARNING 0005W "Censimento $CENS gia Presente"
     sleep $SleepTime
     continue
  fi

  grep "Totale censimenti inseriti = 1" /oradata/ITT0/app/spOrchSuite/bin/runtime/Send_Censimenti/log/$CENS.log 1>/dev/null 2>&1
  rc=$?

  if [ $rc -eq 0 ] ; then
     Log OK 0000K "Caricamento Effettuato Correttamente $FILE"
  elif [ $rc -eq 1 ] ; then
     Log ERROR 00015E "Errore nel Caricamento $FILE"
  elif [ $rc -eq 2 ] ; then
     Log ERROR 00045E "File di Log non Generato"
  else
     Log FATAL 00111F "Error Unexpected"
  fi

  sleep $SleepTime

done