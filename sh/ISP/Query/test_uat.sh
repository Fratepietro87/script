#!/bin/ksh
export RUNPATH=/oradata/ITT0/app/spOrchSuite/bin/runtime/WSRR/Utility/Query
if [ $# -le 1 ]; then
echo "Passare come primo parametro l'ambiente (PROD o SYS o UAT) 
come secondo la directory di output
come terzo la data delta YYYY-MM-DD
come quarto opzionale timeout curl espresso in secondi"
exit 1
 elif [ $# -gt 4 ]; then
echo "Passare come primo parametro l'ambiente (PROD o SYS o UAT) 
come secondo la directory di output
come terzo la data delta YYYY-MM-DD
come quarto opzionale timeout curl espresso in secondi"
exit 1
fi

if [ "$#" -eq 4 ]; then 
export TT=$4
timeout=" --max-time ${TT}"
fi
if [ $1 = "PROD" ]; then 
export AMBIENTE='http://ixpwebservices.bancaintesa.it:9081/WSRR/7.0/Metadata/XML/GraphQuery'
export LAMB='PROD'
elif [ $1 = "SYS" ]; then 
export AMBIENTE='http://ixpwebservices-col.bancaintesa.it:9081/WSRR/7.0/Metadata/XML/GraphQuery'
export LAMB='SYS'
elif [ $1 = "UAT" ]; then 
export AMBIENTE='http://ixpwebservices-uat.bancaintesa.it:9080/WSRR/7.0/Metadata/XML/GraphQuery'
export LAMB='UAT'
else 
echo "ambiente (PROD o SYS o UAT)" 
exit 1
fi
export DELTADATA=$3
time='00:00:00.000'
some_date="$DELTADATA $time"
delta_date=$(date -d "$some_date" +%s000)
export OUTDIR=$2
mkdir -p -- "$OUTDIR"
current_big_export_ts=$(date +%Y%m%d_%H%M%S)
FILELOG=$OUTDIR/WSRREXP_${LAMB}_log.out
exec 1>> $FILELOG 2>&1
echo 
echo --------------- IXPWSRRDELTAEXPORT $some_date in millisecondi $delta_date ---------------



echo ---- Esecuzione Delta in $LAMB Query FT $DELTADATA ----
