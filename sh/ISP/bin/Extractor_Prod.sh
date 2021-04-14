#!/bin/ksh

# =======================================================================================================================
# Tool per effetture l'estrazione dal WSSR di Produzione partendo da file 
# -server 
#		sviluppo 	: 10.2.231.43
# 		collaudo 	: 10.2.231.148
#		produzione	: ixpwsrrconsole.bancaintesa.it
# -port  9080 
# -operation I1  
# -fileTemplate 
#=======================================================================================================================

INSTALLPATH=$ORSU/bin/runtime/Send_Censimenti/WSRR/Utility/Extractor
VIRTUAL_DRIVE=/oradata/ITT0/app/spOrchSuite/bin/runtime/Send_Censimenti/WSRR/java1.4/WSSRLoader


PATHTEMPLATE=$dirwork/cfg
FILETEMPLATE=DaEstrarre
PATHDESTINAZIONE=$dirwork/esistenti/
PATHLOG=$dirwork/log



$VIRTUAL_DRIVE/Extractor.sh  "-server=ixpwsrrconsole.bancaintesa.it" "-port=9081" "-INPUTFILE=$PATHTEMPLATE/$FILETEMPLATE" -DIROUTPUTFILE=$PATHDESTINAZIONE> $PATHLOG/Ext_Prod_$FILETEMPLATE_`date +%Od_%0m_%Oy`.log

exit 0
