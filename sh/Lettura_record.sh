for CODA in `cat Appid_Destid.ini`
do
	for FILE in `grep "$CODA" destination_index.ini`
	do
		if [ $FILE != "$CODA" ]
		then
		echo "$CODA;$FILE">>confY6.csv
		fi
		
	done 
done
