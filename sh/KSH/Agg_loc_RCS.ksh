#!/bin/ksh 
. /usr/local/ccm_include/confmanlink
OldVer=$1	#Versione vecchia
NewVer=$2	#Versione Nuova
FilVer=" "		#Versione reale di un file
Dove=$3		#Work Path
ListaNomi=" "	#
mess="."		#Messaggio in input per la CheckIn
cd $Dove
if [ ! -d RCS ]
then
	mkdir RCS
fi

CercaNomeModulo()
{
NomeHost=`hostname`
ov=`rlog -h Makefile | awk -F"[ :]+" '/symbolic names/ { getline; print $1 }'|tr -d '\t'`
if [ $ov != "comment" ]
then
	if [ "$NomeHost" = "omis123" -a  "$NomeHost" = "omis153" ]
	then
			NMod=`/develop/confman/bin/sver++ B $ov`
		else
			NMod=`/develop/confman/bin/vver++ B $ov`
	fi
	Mod=`echo $NMod|awk '{print $1}'`	#Nome virtuale
else
	if [ $OldVer = "NO_VERSION" -a $NMod = "comment"]
	then
		Mod=`basename $PWD`
	fi
fi

}
AttivitaComune()
{
   	CercaNomeModulo
 	rcs -l $ListaNomi				#Lock dei nomi contenuti nella lista
	ci -m"$mess" $ListaNomi			#Check in dei nomi contenuti nella lista
	co -r$Mod"_"$OldVer RCS/*				#estrazione dei file della versione precedente
	co $ListaNomi				#Estrazione dei nomi contenuti nella lista
}

pwd |grep include
Mio=$?
if [ "$Mio" = "0" ]
then
	for nome in `ls *.h`	#generazione della lista dei sorgenti di cui viene fatta la ci in RCS
	do
		ListaNomi=$ListaNomi" "$nome
	done
	AttivitaComune
	Mod=`basename $Dove`
	for nome in `ls`	#generazione della lista dei sorgenti di cui viene fatta la ci in RCS
	do
		if [ "$nome" != "RCS" -a "$nome" != "Orig" -a "$nome" != "tmp" -a "$nome" != "temp" ]
		then
			Idstr=`ident $nome | grep Id`
			FilVer=`echo $Idstr|cut -f3 -d" "`
			rcs -q -N$Mod"_"$NewVer:$FilVer $Nome
		fi
	done
else
	# Estrazione del nome virtuale
	for nome in `ls`	#generazione della lista dei sorgenti di cui viene fatta la ci in RCS
	do
		if [ "$nome" != "RCS" -a "$nome" !=  "Orig" -a "$nome" != "tmp" -a "$nome" != "temp" ]
		then
			ListaNomi=$ListaNomi" "$nome
		fi
	done
	CercaNomeModulo
	AttivitaComune			#Lancio Funzione comune alle 2 attivita
	make ident
	if [ "$?" = "0" ]
	then
		arch_rel $Mod $NewVer
		if [ "$?" != "0"]
		then
			echo
			echo
			echo
			echo
			echo
			echo
			echo "ATTENZIONE ! ATTENZIONE ! ATTENZIONE ! "
			echo
			echo "Il versionamento di "$Mod" fallita"
			sleep 3
		else
			rcsclean -r$Mod"_"$NewVer
		fi
	fi
fi
. /usr/local/ccm_include/ccmlink
