#---------------------------------------------------------------
# Shell per applicazione PORTALE
#---------------------------------------------------------------
# Estrazione file <Nome file jar>/<Ricompilazione dbrm>/<Ricostruzione file jar>
#
# $1 = cartella in cui si trova il file jar
# $2 = nome del file jar
#---------------------------------------------------------------
if test -n $1 -a -n $2
then
  #recupero il file jar da ricompilare dalla locazione di competenza
# mv /WebSphere390/CB390/apps/BBOSPOR/Agenzia/$2 $1/$2
  cp /WebSphere390/CB390/apps/BBOSPOR/Agenzia/$2 $1/$2

  # scompatta il file jar nella cartella corrente
  echo $1
  echo $2
  jar -xf $1/$2

  # rigenera il dbrm
  # pathfileser = path (a partire da $1) del file .ser da ricompilare
  # nomefileser = nome del file .ser da ricompilare
  # nomedbrm = nome del dbrm che si vuole generare (7 lettere)

  binda.sh $1/it/banksiel/portale/sql DbPor01_SJProfile0.ser            DbPor01
  binda.sh $1/it/banksiel/portale/sql DbPor02_SJProfile0.ser            DbPor02
  binda.sh $1/it/banksiel/portale/sql DbPor03_SJProfile0.ser            DbPor03
  binda.sh $1/it/banksiel/portale/sql DbPor04_SJProfile0.ser            DbPor04
  binda.sh $1/it/banksiel/portale/sql DbPor05_SJProfile0.ser            DbPor05
  binda.sh $1/it/banksiel/portale/sql DbPor06_SJProfile0.ser            DbPor06
  binda.sh $1/it/banksiel/portale/sql DbPor07_SJProfile0.ser            DbPor07
  binda.sh $1/it/banksiel/portale/sql DbPor08_SJProfile0.ser            DbPor08
  binda.sh $1/it/banksiel/portale/sql DbPor09_SJProfile0.ser            DbPor09

  # ripetere il comando per ogni file ser che occorre ricompilare
  # binda.sh $1/pathfileser nomefileser nomedbrm
  # binda.sh $1/pathfileser nomefileser nomedbrm
  # ...
  # binda.sh $1/pathfileser nomefileser nomedbrm

  # ricostruisce il file jar, a partire dalla cartella corrente,
  # includendo il file manifest.mf e tutti i files e le cartelle a
  # partire dalla radice it/
  jar -cfm $1/$2 META-INF/MANIFEST.MF it/

  #sposto il file jar ricompilato nella locazione di competenza
  rm /WebSphere390/CB390/apps/BBOSPOR/Agenzia/$2
  mv $1/$2 /WebSphere390/CB390/apps/BBOSPOR/Agenzia/$2

  #cancello i file esplosi
  rm -r ./it/
  rm -r ./META-INF/
else
   echo "[Errore nella chiamata a shell bindport]"
   echo "[Sintassi del comando] bindport <path del file jar> <nome del file jar>"
fi
