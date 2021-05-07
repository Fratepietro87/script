if test -n $1
then
filein=$1
else
echo "errore nel lancio di creapds.sh"
echo "USAGE: creapds.sh ListaSER_con_path"
fi
if !(-r $filein)
then
echo "ERRORE: il file $filein non e'leggibile"
exit 1
else
earname=`cat $filein |head -n 1 | awk '{ print $5 }'`
fi
tso prof 'prefix(u4981)'
tso allocate 'da($earname) new tracks dir(100) space(10,10) recfm(f,b) lrecl(80) blksize(23440)'
tso prof 'noprefix'
