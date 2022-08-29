#!/bin/ksh
MF_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/Giorgio/TEMP/Cens_MF/produzione


for FILE in `ls  2>/dev/null`
do

QMAN=`awk ' { y=z; z=a; a= b; b=c; c=$0 } c ~ "'"'"'PS'"'"'" { print y; exit } ' $FILE`
 case $QMAN in
\'**POOPER\'\,)
 mv $FILE $MF_P
;;
\'XPEDMERV\'\,)
 mv $FILE $MF_P
esac
	done