#!/bin/ksh

for FLUSSO in `cat flussi.csv`
do
    SanpaoloExtractorPROD.sh $FLUSSO 
	
	done 
