#!/bin/ksh	

#####PATH DEI CENSIMENTI
RUN=/oradata/ITT0/app/spOrchSuite/bin/runtime
WSRR_C=/oradata/ITT0/app/spOrchSuite/bin/runtime/Cens_WSRR/collaudo
WSRR_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/Cens_WSRR/produzione
###################

##COPIO I CENSIMENTI DA CARICARE IN COLLAUDO###
cd $WSRR_P

	for FILE in `grep OSPO * |awk -F ':' '{ print $1 }'`
do
cp $FILE $WSRR_C
cd $WSRR_C
perl -pi -e 's/CFT\_TGT\_FILE\=DOP0/CFT\_TGT\_FILE\=SDS\.DOP0/g' $FILE
perl -pi -e 's/CFT\_TGT\_FILE\=DGP0/CFT\_TGT\_FILE\=SDS\.DGP0/g' $FILE
cd -
done
    
	for FILE in `grep MXED * |awk -F ':' '{ print $1 }'`
do
cp $FILE $WSRR_C
cd $WSRR_C
perl -pi -e 's/CFT\_TGT\_FILE\=DSPX/CFT\_TGT\_FILE\=SDX\.DSPX/g' $FILE
cd -
done

    for FILE in `grep OOQ * |awk -F ':' '{ print $1 }'`
do
cp $FILE $WSRR_C
done





































U7B21.U7B20.S:CFT_SPZ_CODAMQ=OOFOSPO
