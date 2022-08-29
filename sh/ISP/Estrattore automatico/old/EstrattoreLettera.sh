#!/bin/ksh

#set -x

#######################################
#			  	      #
# Sanpaolo Extractor che passandogli  #
# come parametro il Flow Name Crea in #
# bin/Runtime solo i censimenti ed    #
# elimina tutto il resto (Script di   #
# spedizione,JCL,ecc)                 #
# 				      #
#######################################

###Variabili
SqlExecFile=ExecFile.$$
SqlOutputFile=Output.lst.$$
SqlOutputFiletmp=Output.tmp.$$
FLOWNAME=$1
WORK=/oradata/ITT0/app/spOrchSuite/bin/runtime/WORK
RUN=/oradata/ITT0/app/spOrchSuite/bin/runtime/
#############

###Controllo sui parametri e se diversi da f o R o nullo Esce
case $2 in
	-f)
	;;
	-R)
	;;
	"")
	;;
	*)
	echo "\nI Parametri da passare al SanpaoloExtractor.sh non sono corretti\n"
	exit 2
esac
case $3 in
	-f)
	;;
	-R)
	;;
	"")
	;;
	*)
	echo "\nI Parametri da passare al SanpaoloExtractor.sh non sono corretti\n"
	exit 3
esac
########

##Caratteri (commenti) da aggiungere ad ogni riga della query in modo da fare una grep -v
FAKECHAR="--fakechar"

#####Pulisco l'ExecFile
cat /dev/null > $SqlExecFile
#####Pulisco l'Output File
cat /dev/null > $SqlOutputFile

###Setto delle Opzioni nel file di esecuzione della query
echo "SET HEADING OFF;" >> $SqlExecFile
echo "SET ECHO OFF" >> $SqlExecFile
echo "SET TERMOUT OFF" >> $SqlExecFile
echo "SET FEEDBACK OFF" >> $SqlExecFile
echo "SET PAGESIZE 0" >> $SqlExecFile
echo "SET SERVEROUTPUT ON" >> $SqlExecFile
#echo "set sqlprompt '$SqlPrompt'" >> $SqlExecFile
echo "set trimspool on" >> $SqlExecFile
echo "set colsep ," >> $SqlExecFile
echo "SPOOL  $SqlOutputFile;" >> $SqlExecFile
##############################################################

###Query 
    echo "select FLOW_PK $FAKECHAR"  >> $SqlExecFile
    echo "from T_ITT_FLOW $FAKECHAR" >> $SqlExecFile
    echo "where  name='$FLOWNAME' $FAKECHAR" >> $SqlExecFile
    echo "$FAKECHAR ;"  >> $SqlExecFile
#############################

###SPOOL OFF
echo "SPOOL OFF;" >> $SqlExecFile
############

###Carico environment oracle
export ORACLE_HOME=/opt/oracle/app/oracle/product/10.2.0.3
export ORAENV_ASK=NO
export ORACLE_SID=ITT0
##################

###Esecuzione
cat $SqlExecFile | /opt/oracle/app/oracle/product/10.2.0.3/bin/sqlplus ITT_APP/ITT_APP@ITT0 > /dev/null
##########Fine esecuzione

###Greppa via i caratteri aggiunti per pulire l'output e grazie a un file temporaneo riporta l'output in output.lst
grep -v '\-\-fakechar' $SqlOutputFile | grep -v SQL > $SqlOutputFiletmp
cat $SqlOutputFiletmp > $SqlOutputFile
rm $SqlOutputFiletmp
######################

###Remove execfile
rm $SqlExecFile
###############

###Imposta la variabile Flow_PK da passare al vero sanpaolo extractor
FLOWPK=`head -1 $SqlOutputFile | awk '{print $1}'`
#echo "$FLOWPK"
##################

####Controllo che il FLOWPK non sia Null
if [ "$FLOWPK" = "" ]
	then
		echo "\nIl Nome Interscambio Inserito non Esiste\n"
		rm $SqlOutputFile
		exit 4
fi
########################

###Lancio SanpaoloExtractor VERO
cd $WORK
/oradata/ITT0/app/spOrchSuite/bin/runtime/SanpaoloExtractor.sh $FLOWPK $2 $3
#########################

###Pulisce la WORK e sposta il censimento in bin/runtime e torna alla directory precedente
rm $WORK/*.sh 2>/dev/null
rm $WORK/*.cmd 2>/dev/null
rm $WORK/velocity.log* 2>/dev/null
rm $WORK/*JCLNEW* 2>/dev/null

##### Remove per Cloni Dismessi
rm $WORK/*.*.FC 2>/dev/null
rm $WORK/*.*.YC 2>/dev/null
rm $WORK/*.*.T0 2>/dev/null
rm $WORK/*.*.H 2>/dev/null
#############

########Assegno la lettera del clone di partenza (HOST)
cd $WORK

for FILE in `ls * 2>/dev/null`
do
        if [ "$FILE" != *.*.* ]

                then
                /oradata/ITT0/app/spOrchSuite/bin/runtime/letteraCLONE.sh

        fi

        done
####################################

mv * $RUN 2>/dev/null

cd -
###################

###Remove File di Output
rm $SqlOutputFile
################

									####THE END#####
