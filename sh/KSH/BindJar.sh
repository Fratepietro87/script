#***************************************************************
#* 			BindJar.sh
#*
#* Goal: effettuare il bind dei .ser contenuti nel jar 
#*       per cui e' lanciata la shell
#*
#* Parameters: $1 nome del file jar
#*             $2 directory in cui si trova il jar
#*             $3 nome della lista con l'elenco dei .ser
#*             $4 directory in cui si trova la lista del punto 3
#*
#* Author: Luca Brizzolara, Selesta
#* Date: June 2004 
#***************************************************************

if test -n $1 -a -n $2 -a -n $3 -a -n $4
then
  JAR_NAME=$1
  JAR_PATH=$2
  LIST_NAME=$3
  LIST_PATH=$4
  BATCH_NAME=$LIST_PATH/$JAR_NAME.sh
  TEMP_LIST=$LIST_PATH/$JAR_NAME.tmp

#***************************************************************
# Comincio a scrivere il batch con la riga di scompattamento jar
#***************************************************************
  echo "jar -xf $JAR_PATH/$JAR_NAME" > $BATCH_NAME

#***************************************************************
# Ricavo la lista dei soli ser di pertinenza del jar
#***************************************************************

  grep $JAR_NAME $LIST_PATH/$LIST_NAME | awk -v BASE_PATH=$JAR_PATH '{gsub(b"\\\\","\/"); print "binda1.sh " BASE_PATH "/" $1 " " $2 " " $3 }' >> $BATCH_NAME

  

# grep $JAR_NAME $LIST_PATH/$LIST_NAME > $TEMP_LIST
   
  # rigenera il dbrm
  # pathfileser = path (a partire da $1) del file .ser da ricompilare
  # nomefileser = nome del file .ser da ricompilare
  # nomedbrm = nome del dbrm che si vuole generare (7 lettere)

  echo "jar -cfm $JAR_PATH/$JAR_NAME META-INF/MANIFEST.MF it/" >> $BATCH_NAME
  echo "rm -r ./it/" >> $BATCH_NAME
  echo "rm -r ./META-INF/" >> $BATCH_NAME
  chmod 744 $BATCH_NAME
#  $BATCH_NAME 
else
   echo "[Errore nella chiamata a shell BindJar]"
   echo "[Sintassi del comando] BindJar <path del file jar> <nome del file jar> <nome della lista dei ser> <path della lista dei ser>"
fi
