#!/bin/ksh
MF_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/Cens_MF/produzione
WSRR_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/Cens_WSRR/produzione
RUN=/oradata/ITT0/app/spOrchSuite/bin/runtime
WORK=/oradata/ITT0/app/spOrchSuite/bin/runtime/WORK


for FILE in `ls $WORK  2>/dev/null`
do
cd $WORK
QMAN=`awk ' { y=z; z=a; a= b; b=c; c=$0 } c ~ "'"'"'PS'"'"'" { print y; exit } ' $FILE`
 case $QMAN in
\'**POOPER\'\,)
 mv $FILE $MF_P
;;
\'XPEDMERV\'\,)
 mv $FILE $MF_P/$FILE.X
esac
	done
	
for FILE in `ls  2>/dev/null`
mv $FILE $WSSR_P