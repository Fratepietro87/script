#!/bin/ksh

######################################
# script di carimento dei censimenti #
# partenti da MF sia in produzione   #
# che collaudo tramite TWS           #
######################################


#####PATH DEI CENSIMENTI
RUN=/oradata/ITT0/app/spOrchSuite/bin/runtime
MF_P=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_MF/produzione
MF_C=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_MF/collaudo
MF_SP=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_MF/send/produzione
MF_SC=/oradata/ITT0/app/spOrchSuite/bin/runtime/Caricamenti_Censimenti/Cens_MF/send/collaudo
WORK=/oradata/ITT0/app/spOrchSuite/bin/runtime/WORK
BCK=/oradata/ITT0/app/spOrchSuite/bin/runtime/Send_Censimenti/bck
SEND=/oradata/ITT0/app/spOrchSuite/bin/runtime/Send_Censimenti

####UNISCO I TEMPLATE
cd $MF_SP

for FILE in `ls *.*.* 2>/dev/null`
do

        case $FILE in
          *.*.A)
        cat $FILE >> CENS.UNITO.A
        ;;
        *.*.B)
        cat $FILE >> CENS.UNITO.B
        ;;
        *.*.B0)
        cat $FILE >> CENS.UNITO.B0
        ;;
        *.*.C)
        cat $FILE >> CENS.UNITO.C
        ;;
        *.*.C0)
        cat $FILE >> CENS.UNITO.C0
        ;;
        *.*.DC)
        cat $FILE >> CENS.UNITO.DC
        ;;
        *.*.E)
        cat $FILE >> CENS.UNITO.E
        ;;
        *.*.I)
        cat $FILE >> CENS.UNITO.I
        ;;
        *.*.J)
        cat $FILE >> CENS.UNITO.J
        ;;
        *.*.K)
        cat $FILE >> CENS.UNITO.K
        ;;
        *.*.L)
        cat $FILE >> CENS.UNITO.L
        ;;
        *.*.M)
        cat $FILE >> CENS.UNITO.M
        ;;
        *.*.N)
        cat $FILE >> CENS.UNITO.N
        ;;
        *.*.O)
        cat $FILE >> CENS.UNITO.O
        ;;
        *.*.P)
        cat $FILE >> CENS.UNITO.P
        ;;
        *.*.QC)
        cat $FILE >> CENS.UNITO.QC
        ;;
        *.*.Q0)
        cat $FILE >> CENS.UNITO.Q0
        ;;
        *.*.R)
        cat $FILE >> CENS.UNITO.R
        ;;
        *.*.S)
        cat $FILE >> CENS.UNITO.S
        ;;
        *.*.T)
        cat $FILE >> CENS.UNITO.T
        ;;
        *.*.U)
        cat $FILE >> CENS.UNITO.U
        ;;
        *.*.V)
        cat $FILE >> CENS.UNITO.V
        ;;
        *.*.X)
        cat $FILE >> CENS.UNITO.X
        ;;
        *.*.ZC)
        cat $FILE >> CENS.UNITO.ZC
        ;;
         
        esac
		
	done	
## GENERATO I TEMPLATE CENS.UNITO.*

####CREO I TEMPLATE DA CARICARE IN COLLAUDO E PULISCO
		
##TEMPLATE X IL COLLAUDO

cd $MF_SP

cp CENS.UNITO.X $RUN/CENS.UNITO.X.COL  2>>/dev/null/
cp CENS.UNITO.S $RUN/CENS.UNITO.S.COL  2>>/dev/null/

##SPOSTO I TEMPLATE PER LA PRODUZIONE
mv CENS.UNITO.* $RUN 2>>/dev/null/
		
####CARICAMENTO DEI CENSIMENTI
cd $SEND


Send_Host_Clone_System.sh CENS.UNITO.S.COL S 2>>/dev/null/
Send_Host_Clone_System_Mb.sh CENS.UNITO.X.COL X 2>>/dev/null/  
Send_Host_Mb.sh CENS.UNITO.X 2>>/dev/null/
Send_Host_All_Cloni.sh CENS.UNITO 2>>/dev/null/

####SPOSTO I CENSIMENTI NELLA CARTELLA DI BCK

cd $MF_SP

mv *.*.* $BCK
