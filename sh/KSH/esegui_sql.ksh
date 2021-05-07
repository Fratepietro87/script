#!/bin/ksh
. /cll/dati/tras/elf

FILE_SQL=$1
FILE_LOG=$2

export ORACLE_SID=$ORACLE_SID
export ORACLE_HOME=$ORACLE_HOME
export PATH=$PATH:.:$ORACLE_HOME/bin
export USERID=$elbu
export PASSWORD=$elbp

selplus -s $USERID/$PASSSWORD @$FILE_SQL > $FILE_LOG

err1='grep 'ORA-' $FILE_LOG|cut -c 1-9'
err2='grep 'error' $FILE_LOG|cut -c 1-9'
err='expr $err1 + $err2'

if [ "$err" != "0" ]
then
  cat $FILE_LOG|maix -s 'Batch KO' aaa.bbb@mediolanum.it 
  exit 1
else
  cat $FILE_LOG|maix -s 'Batch KO' aaa.bbb@mediolanum.it 
fi
exit 0



