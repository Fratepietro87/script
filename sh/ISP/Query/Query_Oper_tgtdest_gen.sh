#!/bin/ksh
export RUNPATH=/oradata/ITT0/app/spOrchSuite/bin/runtime/WSRR/Utility/Query

set +u

  if [ $# -le 1 ]; then
     echo "Passare come primo parametro l'Operazione\ncome secondo il TGTDEST\ncome terzo parametro l'ambiente (PROD o SYSTEM)"
     exit 1
  elif [ $# -gt 3 ]; then
     echo "Passare come primo parametro l'Operazione\ncome secondo il TGTDEST\ncome terzo parametro l'ambiente (PROD o SYSTEM)"
     exit 1
  fi

  if [ $1 = "-?" ]; then
     echo "script per per eseguire ricerche sul WSRR\nlo scirpt accetta come parametri:\n- Campo (enlencati in ListaCampi.txt)\n- Valore\n- Ambiente \(PROD o SYSTEM)\nnell'ordine indicato\n\nlo script genera un file contenente la lista di tutti i censimenti che contengono l'Operazione indicato"
     exit 55
  elif [ $1 = "-man" ]; then
     echo "script per per eseguire ricerche sul WSRR\nlo scirpt accetta come parametri:\n- Campo (enlencati in ListaCampi.txt)\n- Valore\n- Ambiente \(PROD o SYSTEM)\nnell'ordine indicato\n\nlo script genera un file contenente la lista di tutti i censimenti che contengono l'Operazione indicato"
     exit 55
  fi

export OPERAZIONE=$1
export TGTDEST=$2
export AMBIENTE=$3

        if [ $# = 3 ]; then
  case $AMBIENTE in
           "SYSTEM")

                 curl -g -vvvvvv --get "http://ixpwebservices-col.bancaintesa.it:9081/WSRR/7.0/Metadata/XML/GraphQuery" --data-urlencode "query=/WSRR/GenericObject[matches(@CTL_ID_TGT_DES,'$TGTDEST') and matches(@CTL_ID_OPER,'$OPERAZIONE')  and @namespace='http://www.bancaintesa.com/xmlns/wsrr/catalog']" -o $RUNPATH/Risultati/list_OPERAZIONE.TGTDEST.tmp
                 grep "name\" value\=" $RUNPATH/Risultati/list_OPERAZIONE.TGTDEST.tmp | awk -F"\"" ' /name/ {print $4}' >>$RUNPATH/Risultati/list_OPERAZIONE.TGTDEST
		 rm  $RUNPATH/Risultati/*.tmp

                ;;
                "PROD")

                 curl -g -vvvvvv --get "http://ixpwebservices.bancaintesa.it:9081/WSRR/7.0/Metadata/XML/GraphQuery" --data-urlencode "query=/WSRR/GenericObject[matches(@CTL_ID_TGT_DES,'$TGTDEST') and matches(@CTL_ID_OPER,'$OPERAZIONE')  and @namespace='http://www.bancaintesa.com/xmlns/wsrr/catalog']" -o $RUNPATH/Risultati/list_OPERAZIONE.TGTDEST.tmp
                 grep "name\" value\=" $RUNPATH/Risultati/list_OPERAZIONE.TGTDEST.tmp | awk -F"\"" ' /name/ {print $4}' >>$RUNPATH/Risultati/list_OPERAZIONE.TGTDEST
		 rm  $RUNPATH/Risultati/*.tmp

        ;;
       *)
            echo "avete scelto un ambiente diverso da PROD o SYSTEM"
            exit 2
       ;;
  esac
        elif [ $# != 3 ]; then
     echo "Passare come primo parametro l'Operazione\ncome secondo il TGTDEST\ncome terzo parametro l'ambiente (PROD o SYSTEM)"
     exit 1
         fi

