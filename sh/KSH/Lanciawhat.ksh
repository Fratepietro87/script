#!/bin/ksh

#*******************************************************************************
#*                        Compila_iface.csh
#*
#* Goal: Lancia what per verificare i programmi da ricompilare 
#* Parametri: $1 file di lock
#*            $2 elenco routine 
#*            $3 elenco file da ricompilare 
#* Author:	Barbara Battistelli (COmitsiel)
#* 			Luca Brizzolara (Selesta) 
#*******************************************************************************

LOCK=$1
LISTAR=$2
ELENCO=$3

# Genero il file di lock prima di iniziare 
touch $LOCK 

# con il what verifico quali programmi richiamano le routine in oggetto
cd /u/dsim/bin
for f in `ls`
do
  ESITO=`what $f  2>/dev/null| grep -E "${LISTAR}"`
  if [[ $ESITO != "" ]]
  then
    echo $f >> ${ELENCO}
  fi
done

# alla fine levo il lock
rm $LOCK

exit 0




