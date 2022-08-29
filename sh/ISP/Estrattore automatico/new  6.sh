#!/bin/ksh	

##########################################
# script per caricamento dei censimenti  #
# IXP-FT sul WSRR di sviluppo al fine di #
# creare i censimenti per l'ambiente di  #
# MIG                                    #
##########################################

#####PATH 
RUN=/oradata/ITT0/app/spOrchSuite/bin/runtime
WSRR_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/MIG/Cens_WSRR/produzione
WSRR_SP=/oradata/ITT0/app/spOrchSuite/bin/runtime/MIG/Cens_WSRR/send/produzione
WSRR_C=/oradata/ITT0/app/spOrchSuite/bin/runtime/MIG/Cens_WSRR/collaudo
WSRR_SC=/oradata/ITT0/app/spOrchSuite/bin/runtime/MIG/Cens_WSRR/send/collaudo
WORK=/oradata/ITT0/app/spOrchSuite/bin/runtime/WORK
INSTALLPATH=$ORSU/bin/runtime/Send_Censimenti/WSRR
VIRTUAL_DRIVE=$INSTALLPATH/java1.4
PATHLOG=$ORSU/bin/runtime/Send_Censimenti/log
PATHBCK=$ORSU/bin/runtime/Send_Censimenti/bck

##COPIO I CENSIMENTI DA CARICARE IN SVILUPPO PER MIG###
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
#done

####CARICAMENTO CENSIMENTI IN PRODUZIONE

##INIZIO CARICAMENTO

for FILE in `ls $WSRR_SP/*.*`
do
  CENS=`basename $FILE`
  $VIRTUAL_DRIVE/WSSRLoader/Loader.sh  $VIRTUAL_DRIVE  "-server=10.2.231.43" "-port=9080" "-operation=I1"  "-fileTemplate=$WSRR_P/$CENS" > $PATHLOG/$CENS.log

mv $WSRR_SP/$CENS $PATHBCK

## FINE CARIMENTO PRODUZIONE