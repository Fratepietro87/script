#!/bin/ksh
#--------------------------------------------------------------------------  
#   Goal    :   Lancia il file sisobd.she ridirigendo l'output e l'error in  
#               un file di log                                               
#                                                                            
#--------------------------------------------------------------------------  

SISO_NAME=$1
LOG_NAME=$2
. /u/dsim/.profile
cd /u/dsim/siso
./$SISO_NAME >$LOG_NAME 2>&1
exit 0
