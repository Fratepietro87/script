#-------------------------------------------------------------
# Effettua il bind di sql statico
#
# $1  = path completo del file ser
# $2  = nome del file ser
# $3  = nome del dbrm (7 caratteri)
#-------------------------------------------------------------
 if test -n $1 -a -n $2 -a -n $3
 then
   echo "[Spostamento di " $1 "/" $2 " nella cartella corrente]"
   mv $1/$2  $2
   echo "[Chiamata a db2profc per " $1 "/" $2 " dbrm = " $3 "]"
#  db2profc  -pgmname=$3 $2				# db2profc SENZA on-line checking
   db2profc -online=BPERDB2C -schema=MO -pgmname=$3 $2	# db2profc CON on-line checking
   echo "[Eseguito db2profc per " $1 "/" $2 " dbrm = " $3 "]"
   mv $2 $1/$2
   echo "[Spostamento di " $2 " in " $1 "/" $2 "]"
 else
   echo "[Errore nella chiamata a shell bindash]"
   echo "[Sintassi del comando] bindash <path del file jar> <nome del file jar> <nome dbrm>"
 fi
