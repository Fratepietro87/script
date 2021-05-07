#!/bin/ksh
# Parametri in ingresso dell'utente <path_consegna> <tt_server> <tt_issueid> <coll_ok | coll_ko | prod_ok | prod_ko> <commento>
# Parametri dello script batch windows <tt_user> <tt_password> <tt_table>
if [ $# -ne 5 ]; then
        echo ""
        echo "Errore. Numero di parametri non corretto."
        echo "I parametri devono essere i seguenti: "
        echo ""
        echo "<path_consegna> <tt_server> <tt_issueid> <'coll_ok'|'coll_ko'|'prod_ok'|'prod_ko'> <commento>"
        echo ""
        exit 1
fi
if [ $4 != "coll_ok" ] && [ $4 != "coll_ko" ] && [ $4 != "prod_ok" ] && [ $4 != "prod_ko" ]; then
        echo ""
        echo "Errore. Il parametro dello stato (quarto) deve avere uno dei seguenti valori:"
        echo ""
        echo "'coll_ok' --> Passaggio in collaudo avvenuto con successo."
        echo "'coll_ko' --> Passaggio in collaudo fallito."
        echo "'prod_ok' --> Passaggio in produzione avvenuto con successo."
        echo "'prod_ko' --> Passaggio in produzione fallito."
        echo ""
        exit 1
fi

echo $1 > ./TT_RESULT
echo $2 >> ./TT_RESULT
echo $3 >> ./TT_RESULT
echo $4 >> ./TT_RESULT
echo $5 >> ./TT_RESULT

ftp -n prwb1gnms001 <<END_SCRIPT
quote USER dmsys
quote PASS dmsys05
cd $1/TT_LINK
put TT_RESULT
get TT_RESULT retrieval.$$
quit
END_SCRIPT

if [ -f retrieval.$$ ]
then
#      echo "FTP di TT_RESULT su prwb1gnms001 OK."
       rm -f ./retrieval.$$
       rm -f ./TT_RESULT
#      exit 0
else
#      echo "FTP di TT_RESULT su prwb1gnms001 fallito."
       rm -f ./TT_RESULT
#      exit 1
fi

echo "OFF" > ./TT_SEM

ftp -n prwb1gnms001 <<END_SEM
quote USER dmsys
quote PASS dmsys05
cd $1/TT_LINK
put TT_SEM
get TT_SEM retrieval.$$
quit
END_SEM

if [ -f retrieval.$$ ]
then
#      echo "FTP di TT_SEM su prwb1gnms001 OK."
       rm -f ./retrieval.$$
       rm -f ./TT_SEM
       exit 0
else
#      echo "FTP di TT_SEM su prwb1gnms001 fallito."
       rm -f ./TT_SEM
       exit 1
fi

