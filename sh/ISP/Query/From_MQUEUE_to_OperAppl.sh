#!/bin/ksh
export RUNPATH=/oradata/ITT0/app/spOrchSuite/bin/runtime/WSRR/Utility/Query

set +u

  if [ $# -le 1 ]; then
     echo "Passare come primo parametro il Campo\ncome secondo il valore\ncome terzo parametro l'ambiente (PROD o SYSTEM)"
     exit 1
  elif [ $# -gt 2 ]; then
     echo "Passare come primo parametro il Campo\ncome secondo il valore\ncome terzo parametro l'ambiente (PROD o SYSTEM)"
     exit 1
  fi

  if [ $1 = "-?" ]; then
     echo "script per per eseguire ricerche sul WSRR\nlo scirpt accetta come parametri:\n- Campo (enlencati in ListaCampi.txt)\n- Valore\n- Ambiente \(PROD o SYSTEM)\nnell'ordine indicato\n\nlo script genera un file contenente la lista di tutti i censimenti che contengono il campo indicato"
     exit 55
  elif [ $1 = "-man" ]; then
     echo "script per per eseguire ricerche sul WSRR\nlo scirpt accetta come parametri:\n- Campo (enlencati in ListaCampi.txt)\n- Valore\n- Ambiente \(PROD o SYSTEM)\nnell'ordine indicato\n\nlo script genera un file contenente la lista di tutti i censimenti che contengono il campo indicato"
     exit 55
  fi

export VALUE=$1	
export AMBIENTE=$2

	if [ $# = 2 ]; then
  case $AMBIENTE in
	   "SYSTEM")
	
		 curl -g -vvvvvv --get "http://ixpwebservices-col.bancaintesa.it:9081/WSRR/7.0/Metadata/XML/GraphQuery" --data-urlencode "query=/WSRR/GenericObject[matches(@DIR_CODA_MQ,'$VALUE.*') and @namespace='http://www.bancaintesa.com/xmlns/wsrr/directory']" -o $RUNPATH/Risultati/CODAWMQ.$VALUE.tmp
		 grep "name\" value\=" $RUNPATH/Risultati/CODAWMQ.$VALUE.tmp | awk -F"\"" ' /name/ {print $4}' >>$RUNPATH/Risultati/list_CODAWMQ.$VALUE
          rm $RUNPATH/Risultati/*tmp
	 
		;;
		"PROD")
	
		 curl -g -vvvvvv --get "http://ixpwebservices.bancaintesa.it:9081/WSRR/7.0/Metadata/XML/GraphQuery" --data-urlencode "query=/WSRR/GenericObject[matches(@DIR_CODA_MQ,'$VALUE.*') and @namespace='http://www.bancaintesa.com/xmlns/wsrr/directory']" -o $RUNPATH/Risultati/CODAWMQ.$VALUE.tmp
		 grep "name\" value\=" $RUNPATH/Risultati/CODAWMQ.$VALUE.tmp | awk -F"\"" ' /name/ {print $4}' >>$RUNPATH/Risultati/list_CODAWMQ.$VALUE
         rm $RUNPATH/Risultati/*tmp
	
        ;;
       *)
            echo "avete scelto un ambiente diverso da PROD o SYSTEM"
            exit 2
       ;;
  esac
	elif [ $# != 2 ]; then
     echo "Passare come primo parametro il Campo\ncome secondo il valore\ncome terzo parametro l'ambiente (PROD o SYSTEM)"
     exit 1
	 fi

### pulisco 
echo "DIRECTORY;FILETRANSFER" >$RUNPATH/Risultati/$VALUE.$AMBIENTE.censimenti

while IFS="_"
read OPER TGTDEST AMBLOG
do
$RUNPATH/Query_Oper_tgtdest.sh $OPER $TGTDEST $AMBLOG $AMBIENTE
export FILETRANSFER=$(tail -1  $RUNPATH/Risultati/list_OPERAZIONE.TGTDEST)
echo "$OPER\_$TGTDEST\_$AMBLOG;$FILETRANSFER" >> $RUNPATH/Risultati/$VALUE.$AMBIENTE.censimenti



done< $RUNPATH/Risultati/list_CODAWMQ.$VALUE
perl -pi -e 's/\\//g' $RUNPATH/Risultati/$VALUE.$AMBIENTE.censimenti

