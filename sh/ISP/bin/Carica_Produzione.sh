#!/bin/ksh

unique_id=`echo $$`
SleepTime=5
inputfile=$1
export dirwork=$RUN/BFD
export dirlogcari=$RUN/Send_Censimenti/log/
export dirinput=$dirwork/input
export dirlog=$dirwork/log
export dircfg=$dirwork/cfg
export dirbin=$dirwork/bin
export dircensp=$dirwork/censimenti_produzione
export dircenss=$dirwork/censimenti_system
export dirdone=$dirwork/done
export diresi=$dirwork/esistenti
export dirwsrr=$RUN/WSRR
export logcar=$dirlog/Caricamento_$inputfile.log

Log() {
echo \[${unique_id}\] \| $1 \| "$2" >> $logcar
}
mkdir $dirdone/$1

for FILE in `ls $dircensp/* `
do
  CENS=`basename $FILE`
  cp $dircensp/$CENS $RUN
  export rcex=$?
  if [ $rcex -ne 0 ]
    then
  		Log CRITICAL "Errore nell'estrazione dal WSRR" 
  		Log CRITICAL "RC:$rcex" 
    exit 1  
   fi
  $dirwsrr/Aclient_Produzione.sh $CENS 2>/dev/null

  grep "presente nel Registry" $dirlogcari/$CENS.log 1>/dev/null 2>&1
  rc=$?

  if [ $rc -eq 0 ] ; then
     Log WARNING "Censimento $CENS gia Presente"
     sleep $SleepTime
     continue
  fi

  grep "Totale censimenti inseriti = 1" $dirlogcari/$CENS.log 1>/dev/null 2>&1
  rc=$?

  if [ $rc -eq 0 ] ; then
     Log INFO "Caricamento Effettuato Correttamente $FILE"
	 mv $dircensp/$CENS $dirdone/$1
  elif [ $rc -eq 1 ] ; then
     Log ERROR "Errore nel Caricamento $FILE"
  elif [ $rc -eq 2 ] ; then
     Log ERROR "File di Log non Generato"
  else
     Log CRITICAL "Error Unexpected"
  fi

  sleep $SleepTime

done
