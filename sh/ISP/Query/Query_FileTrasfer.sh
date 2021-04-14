#!/bin/ksh
export RUNPATH=/oradata/ITT0/app/spOrchSuite/bin/runtime/WSRR/Utility/Query

set +u

  if [ $# -le 1 ]; then
     echo "Passare come primo parametro il Campo\ncome secondo il valore\ncome terzo parametro l'ambiente (PROD o SYSTEM)"
     exit 1
  elif [ $# -gt 3 ]; then
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

export PROPERTY=$1
export VALUE=$2	
export AMBIENTE=$3

	if [ $# = 3 ]; then
  case $AMBIENTE in
	   "SYSTEM")
	
		 curl -g -vvvvvv --get "http://ixpwebservices-col.bancaintesa.it:9081/WSRR/7.0/Metadata/XML/GraphQuery" --data-urlencode "query=/WSRR/GenericObject[matches(@$PROPERTY,'$VALUE.*') and @namespace='http://www.bancaintesa.com/xmlns/wsrr/filetransfer']" -o $RUNPATH/Risultati/$PROPERTY.$VALUE.tmp
		 grep "\<property\ name\=\"name\"\ value\=" $RUNPATH/Risultati/$PROPERTY.$VALUE.tmp >> $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
		 perl -pi -e 's/\<property\ name\=\"name\"\ value\=//g' $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
		 perl -pi -e 's/_/\ /g' $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
		 perl -pi -e 's/\ \ \ \ \ \ \"//g' $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
		 perl -pi -e 's/\"\/\>//g' $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
       #  rm  $RUNPATH/Risultati/*.tmp
       #  rm *tmp
	 
		;;
		"PROD")
	
		 curl -g -vvvvvv --get "http://ixpwebservices.bancaintesa.it:9081/WSRR/7.0/Metadata/XML/GraphQuery" --data-urlencode "query=/WSRR/GenericObject[matches(@$PROPERTY,'$VALUE.*') and @namespace='http://www.bancaintesa.com/xmlns/wsrr/filetransfer']" -o $RUNPATH/Risultati/$PROPERTY.$VALUE.tmp
		 grep "\<property\ name\=\"name\"\ value\=" $RUNPATH/Risultati/$PROPERTY.$VALUE.tmp >> $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
		 perl -pi -e 's/\<property\ name\=\"name\"\ value\=//g' $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
		 perl -pi -e 's/_/\ /g' $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
		 perl -pi -e 's/\ \ \ \ \ \ \"//g' $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
		 perl -pi -e 's/\"\/\>//g' $RUNPATH/Risultati/list_$PROPERTY.$VALUE.tmp
        # rm  $RUNPATH/Risultati/*.tmp	
        # rm *tmp
	
        ;;
       *)
            echo "avete scelto un ambiente diverso da PROD o SYSTEM"
            exit 2
       ;;
  esac
	elif [ $# != 3 ]; then
     echo "Passare come primo parametro il Campo\ncome secondo il valore\ncome terzo parametro l'ambiente (PROD o SYSTEM)"
     exit 1
	 fi
