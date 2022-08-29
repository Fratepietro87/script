#!/bin/ksh	

#####PATH 
RUN=/oradata/ITT0/app/spOrchSuite/bin/runtime
WSRR_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/produzione
WSRR_C=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_WSRR/collaudo
WORK=/oradata/ITT0/app/spOrchSuite/bin/runtime/WORK
###################

##COPIO I CENSIMENTI DA CARICARE IN COLLAUDO###
cd $WSRR_P

	for FILE in `grep OSPO * |awk -F ':' '{ print $1 }'`
do
cp $FILE $WSRR_C
cd $WSRR_C
perl -pi -e 's/CFT\_TGT\_FILE\=DOP0/CFT\_TGT\_FILE\=SDS\.DOP0/g' $FILE
perl -pi -e 's/CFT\_TGT\_FILE\=DGP0/CFT\_TGT\_FILE\=SDS\.DGP0/g' $FILE
cd -
done
    
	for FILE in `grep MXED * |awk -F ':' '{ print $1 }'`
do
cp $FILE $WSRR_C
cd $WSRR_C
perl -pi -e 's/CFT\_TGT\_FILE\=DSPX/CFT\_TGT\_FILE\=SDX\.DSPX/g' $FILE
cd -
done

    for FILE in `grep OOQ * |awk -F ':' '{ print $1 }'`
do
cp $FILE $WSRR_C
done


####CARICAMENTO CENSIMENTI IN PRODUZIONE

##FILE DI LOG
LOGP=$WSRR_P/log/Caricamenti$(date '+%Y-%m-%d_%H:%M:%S').log
Log() {
echo $(date '+%Y-%m-%d %H:%M:%S') \| $1 \| $$ \| TH$2 \| "$3" >> $LOGP
}

SleepTime=5

##INIZIO CARICAMENTO
cd $RUN/WSRR

for FILE in `ls WSRR_P/*.*`
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

mv $FILE $RUN/Send_Censimenti_bck

## FINE CARIMENTO PRODUZIONE

####CARICAMENTO CENSIMENTI IN COLLAUDO

##FILE DI LOG
LOGC=$WSRR_C/log/Caricamenti$(date '+%Y-%m-%d_%H:%M:%S')Col.log
Log() {
echo $(date '+%Y-%m-%d %H:%M:%S') \| $1 \| $$ \| TH$2 \| "$3" >> $LOGC
}

SleepTime=5

##INIZIO CARICAMENTO
cd $RUN/WSRR

for FILE in `ls $WSRR_C/*.*`
do

  CENS=`basename $FILE`
  Aclient_Collaudo.sh $/$CENS 2>/dev/null

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

rm $FILE

##FINE CARICAMENTO COLLAUDO