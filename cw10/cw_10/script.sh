#!/bin/bash

#=============================================================================#

#SCRIPT.SH

# Script downloads file from provided link, filtrates wron lines,
#load content to db, downloads from db, sends mails ect.     

#=============================================================================#

if [ $# -le 7 ]
  then
    echo "WRONG NUMBER OF ARGUMENTS PROVIDED"
	echo "Usage: <link to_file_to_download> <password_for unziping> <db_user_name> <db_password> <sb_server_address> <db_port> <index_nb> <mail> "
	# ./script.sh http://home.agh.edu.pl/~wsarlej/dyd/bdp2/materialy/cw10/InternetSales_new.zip bdp2agh anawiesn rPdPkVyeVTqdgwXn mysql.agh.edu.pl 3306 290923 mail@mail
	exit 1
fi

if [ -d "PROCESSED" ]; then
	:
else
	mkdir PROCESSED
fi

T0=`date +%Y-%m-%d_%H-%M-%S`
logs_file="$0_$T0.log"

###############################################
#pobierze plik z internetu:
echo "Downloading file"
wget -q -nv $1

if [ $? -ne 0 ];then
	echo "ERROR $? - File could not be downloaded"
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Downloading - ERROR" >> PROCESSED/"$logs_file"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Downloading - SUCCESS" >> PROCESSED/"$logs_file"
fi
################################################
echo "Unziping file"
zzipo=$(basename "$1")
unzip -q -o -P $2 "$zzipo" #InternetSales_new.zip
if [ $? -ne 0 ];then
	echo "ERROR $? - File could not be unzipped"
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Unziping - ERROR" >>PROCESSED/"$logs_file"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Unziping - SUCCESS" >>PROCESSED/"$logs_file"
fi
#IF IS INSTALLED THIS IS ALSO GOOD TO DO: dos2unix InternetSales_new.txt

file1="file.txt"
file2="bad.txt"
file3="unikalne.txt"
file4="kolumny.txt"
file5="quantitygood.txt"
file6="bad1.txt"
file7="new.txt"
file8="c1.txt"
file9="pipe.txt"
file10="order.txt"
file11="InternetSales_new_created.txt"
if [ -s "$file1" ]
then 
   rm "$file1"
else
   touch "$file1"
fi
if [ -s "$file2" ]
then 
   rm "$file2"
else
   touch "$file2"
fi
echo "$zzipo" > f1
sed -i "s/.zip/.txt/" f1 
f2=`cat f1`
rm f1

if [ -s "$f2" ]
then  :
else
   echo "File $f2 does not exist"
    rm "$file1"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
   exit 1
fi
################################################
echo "Removing empty lines"
cp "$f2" file.txt 
sed -i 's/|/\t/g' file.txt

all_file=`wc -l < file.txt`
sed -i '/^[[:space:]]*$/d' file.txt 

if [ $? -ne 0 ];then
	echo "ERROR $? - Empty lines were not deleted"
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Deleting empty lines - ERROR" >>PROCESSED/"$logs_file"
    rm "$file1"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Deleting empty lines - SUCCESS" >>PROCESSED/"$logs_file"
fi

sed -i 's/\t/|/g' file.txt
spaces=`wc -l < file.txt`
################################################
#comparing and moving empty lines to badfile
awk 'NR==FNR{a[$0];next}!($0 in a)' file.txt "$f2" >> bad.txt

if [ $? -ne 0 ];then
	echo "ERROR $? - Moving empty lines to bad_file "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Moving empty lines to bad_file - ERROR" >>PROCESSED/"$logs_file"
    rm "$file1"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Moving empty lines to bad_file - SUCCESS" >>PROCESSED/"$logs_file"
fi

if [ -s "$file3" ]
then 
   rm "$file3"
else
   touch "$file3"
fi
cat -n file.txt | sort -uk2 | sort -nk1 | cut -f2- >> unikalne.txt

if [ $? -ne 0 ];then
	echo "ERROR $? - Unifying file "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Leaving unique lines - ERROR" >>PROCESSED/"$logs_file"
    rm "$file1"
	rm "$file3"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Leaving unique lines - SUCCESS" >>PROCESSED/"$logs_file"
fi
######################################################
#compare and move duplicated lines to badfile
#awk 'NR==FNR{a[$0];next}!($0 in a)' unikalne.txt file.txt >> bad.txt
#move duplicated lines to bad file
if [ -s "dupl.txt" ]
then 
   rm "dupl.txt"
fi
awk 'visited[$0]++ { print $0 }' file.txt >> dupl.txt
duplikats=`wc -l < dupl.txt`
cat dupl.txt >> bad.txt
rm "$file1"
rm "dupl.txt"
########################################################
echo "Leaving column length columns"
tmp1=`head -n 1 unikalne.txt | awk -F '|' '{print NF}'`
if [ -s "$file4" ]
then 
   rm "$file4"
else
   touch "$file4"
fi

awk -v var=$tmp1 -F '|' '{if (NF=var)print $0}' OFS='|' unikalne.txt >> kolumny.txt

if [ $? -ne 0 ];then
	echo "ERROR $? - Column length "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - LEaving columns with certain length - ERROR" >>PROCESSED/"$logs_file"
    rm "$file4"
	rm "$file3"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - LEaving columns with certain length - SUCCESS" >>PROCESSED/"$logs_file"
fi
#compare and move wrong nr of col file to badfile
tr -s "|" < kolumny.txt > kolumny2.txt
awk -F'|' 'NR==FNR{a[$0];next}!($0 in a)' OFS='|' kolumny2.txt unikalne.txt >> bad.txt
rm "$file3"
if [ -s "$file5" ]
then 
   rm "$file5"
else
   touch "$file5"
fi
################################################
echo "Checking order quantity"
awk -F'|' 'NR>1{if($5>100) print $0}' OFS='|' kolumny2.txt >> bad.txt
head -n 1 kolumny2.txt >> quantitygood.txt
awk -F'|' 'NR>1{if($5<=100) print $0}' OFS='|' kolumny2.txt >> quantitygood.txt

if [ $? -ne 0 ];then
	echo "ERROR $? - Counting Quantity"
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Quantity - ERROR" >>PROCESSED/"$logs_file"
    rm "$file4"
    rm "$file5"
	rm "kolumny2.txt"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Quantity - SUCCESS" >>PROCESSED/"$logs_file"
fi


#THIS ALSO WORKS, BUT SLOWLY
#IFS='|'
#tmp=100
#while read line; do
#  items=($line)
#  strlen=${items[4]} #kolumna OrderQuantity
#  if [[ $strlen -le $tmp ]] ;then
#    echo $line | sed '/^$/d' | sed "s/ *$//; s/[[:space:]]\+/|/g; s/$/|/" >> quantitygood.txt
#  else
#    echo $line | sed '/^$/d' | sed "s/ *$//; s/[[:space:]]\+/|/g; s/$/|/" >> bad.txt
#  fi
#done < kolumny.txt

rm "kolumny2.txt"
rm "$file4"
if [ -s "$file6" ]
then 
   rm "$file6"
else
   touch "$file6"
fi
if [ -s "$file7" ]
then 
   rm "$file7"
else
   touch "$file7"
fi
##############################################
echo "Comparing with old file"
#compare new and old
if [ -s "InternetSales_old.txt" ]
then 
   :
else
   echo "Filr InternetSales_old.txt is not provided"
    rm "$file5"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	rm "$file6"
	rm "$file7"
   exit 1
fi
cp InternetSales_old.txt InternetSales_old2.txt
sed -i '1d' InternetSales_old2.txt
awk -F'|' 'NR==FNR{a[$0];next}!($0 in a)' OFS='|' InternetSales_old2.txt quantitygood.txt >> new.txt

if [ $? -ne 0 ];then
	echo "ERROR $? - Comparing with old file "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Comparing with old - ERROR" >>PROCESSED/"$logs_file"
    rm "$file5"
	rm "InternetSales_old2.txt"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Comparing with ol - SUCCESS" >>PROCESSED/"$logs_file"
fi
rm "$file5"
#compare old and move to bad file
awk -F'|' 'NR==FNR{a[$0];next}!($0 in a)' OFS='|' new.txt InternetSales_old2.txt >> bad1.txt
rm "InternetSales_old2.txt"
echo "Remove secret code"
echo "from old" >> bad.txt
#JUST STH THAT COULD WORK BUT IS NOT YET THAT WAY
#awk -F'|' '$7!=""' OFS='|' bad.txt
#awk -F'|' 'NR>1{if($7="") print $0}' OFS='|' bad1.txt > bad2
#awk 'NF{NF-=1};1' <bad2 >> bad.txt

#NO SECRET CODE
awk -F'|' 'NR>1{if(!$7) print $0}' OFS='|' bad1.txt >> bad.txt
#WITH SECRET CODE
awk -F'|' 'NR>1{if($7){NF-=1; print $0}}' OFS='|' bad1.txt >> bad.txt

#IFS='|'
#tmp=1
#while read line; do
#  items=($line)
#  strlen=${#items[6]}
#  nb=${#line[@]}
#  if [[ $strlen -le $tmp ]];then
#    echo $line | sed '/^$/d' | sed "s/ *$//; s/[[:space:]]\+/|/g; s/$/|/" >> bad.txt
#  else
#   #DELETE SECRET CODE AND THEN MOVE TO badfile
#	#echo $line | sed '/^$/d' | sed "s/ *$//; s/[[:space:]]\+/|/g; s/$/|/" >> bad.txt
#  fi
#done < bad1.txt
rm "$file6"

if [ -s "$file8" ]
then 
   rm "$file8"
else
   touch "$file8"
fi
if [ -s "$file9" ]
then 
   rm "$file9"
else
   touch "$file9"
fi
if [ -s "$file10" ]
then 
   rm "$file10"
else
   touch "$file10"
fi
if [ -s "$file11" ]
then 
   rm "$file11"
else
   touch "$file11"
fi
##########################################
echo "Changing CustomerName"
awk -F '|' '{gsub(/"/, "", $3)}1' OFS='|' new.txt >> c1.txt
if [ $? -ne 0 ];then
	echo "ERROR $? - When substituting"
	rm "$file8"
	rm "$file9"
	rm "$file10"
	rm "$file11"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	exit 1
else
	:
fi
tmp2="ProductKey|CurrencyAlternateKey|First_Name|Last_Name|OrderDateKey|OrderQuantity|UnitPrice|SecretCode|"
rm "$file7"
awk -F '|' '{gsub(/,/, "|", $3)}1' OFS='|' c1.txt >> pipe.txt
if [ $? -ne 0 ];then
	echo "ERROR $? - When substituting"
	rm "$file8"
	rm "$file9"
	rm "$file10"
	rm "$file11"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	exit 1
else
	:
fi
awk -F '|' '{ t = $3; $3 = $4; $4 = t; print; } ' OFS='|' pipe.txt  >> order.txt
if [ $? -ne 0 ];then
	echo "ERROR $? - Changing Customer Name "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Changing Name - ERROR" >>PROCESSED/"$logs_file"
	rm "$file8"
	rm "$file9"
	rm "$file10"
	rm "$file11"
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
	touch InternetSales_new.bad_${TIMESTAMP}
	cp bad.txt InternetSales_new.bad_${TIMESTAMP}
    rm "$file2"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Changing Name - SUCCESS" >>PROCESSED/"$logs_file"
fi
sed -i "1s/.*/$tmp2/" order.txt >> InternetSales_new_created.txt
cp order.txt InternetSales_new_created.txt
rm "$file8"
rm "$file9"
rm "$file10"
poprawne=`wc -l < InternetSales_new_created.txt`
TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
touch InternetSales_new.bad_${TIMESTAMP}
cp bad.txt InternetSales_new.bad_${TIMESTAMP}
zle=`wc -l < bad.txt`
rm "$file2"

#========================================================
#========================================================
db_passwd=$(echo "$4" | base64 -d)
export MYSQL_PWD=$db_passwd

tmp3=`head -n 1 InternetSales_new_created.txt | awk -F '|' '{print $0}'`
echo $tmp3 > tmp

v1=$(cut -d '|' -f 1 tmp)
v2=$(cut -d '|' -f 2 tmp)
v3=$(cut -d '|' -f 3 tmp)
v4=$(cut -d '|' -f 4 tmp)
v5=$(cut -d '|' -f 5 tmp)
v6=$(cut -d '|' -f 6 tmp)
v7=$(cut -d '|' -f 7 tmp)
v8=$(cut -d '|' -f 8 tmp)
rm tmp

#echo "Creating DB"
#w bazie MySQL utworzy tabelę CUSTOMERS_${NUMERINDEKSU}
NUMERINDEKSU=$7
#DATABASE=anawiesn
#RESULT=`mysql -u $3 -p$4 -h $5 -P $6 -e --skip-column-names -e "SHOW DATABASES;"`
##RESULT=`mysql -u anawiesn -prPdPkVyeVTqdgwXn -h mysql.agh.edu.pl -P 3306 --skip-column-names -e "SHOW DATABASES";`
#VAR2=`echo "$RESULT" | grep -oP 'anaw.*?\b'`

#if [ "$VAR2" == "$DATABASE" ]; then
#   echo "Database already exist, no need for creating"
#else
#	echo "Creating db"
#    mysql -u $3 -p$4 -h $5 -P $6 --silent -e "CREATE DATABASE anawiesn"
	##mysql -u anawiesn -prPdPkVyeVTqdgwXn -h mysql.agh.edu.pl -P 3306 -e "CREATE DATABASE anawiesn"
 #fi
echo "Creating table in DB"

mysql -u $3 -h $5 -P $6 --silent -e "USE anawiesn; CREATE TABLE IF NOT EXISTS CUSTOMERS_${NUMERINDEKSU}($v1 INTEGER,$v2 VARCHAR(10),$v3 VARCHAR(200),$v4 VARCHAR(200),$v5 VARCHAR(200),$v6 VARCHAR(200),$v7 FLOAT,$v8 VARCHAR(20));" 2>/dev/null

if [ $? -ne 0 ];then
	echo "ERROR $? - Creating table in DB "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Creating table - ERROR" >>PROCESSED/"$logs_file"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Creating table - SUCCESS" >>PROCESSED/"$logs_file"
fi

awk -F'|' 'NR>1{print $0}' OFS='|' InternetSales_new_created.txt > IS.txt
sed -i 's/,/./g' IS.txt

echo "Uplading file to table"
#załaduje dane ze zweryfikowanego plikudo tabeli CUSTOMERS_${NUMERINDEKSU}
mysql -u $3 -h $5 -P $6 --silent -e "USE anawiesn; LOAD DATA LOCAL INFILE 'IS.txt' INTO TABLE CUSTOMERS_${NUMERINDEKSU} FIELDS TERMINATED BY '|';" 2>/dev/null

if [ $? -ne 0 ];then
	echo "ERROR $? - Loading data to DB "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - DB load data - ERROR" >>PROCESSED/"$logs_file"
	rm IS.txt
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - DB load data - SUCCESS" >>PROCESSED/"$logs_file"
fi

#Execution directly from terminal 
#mysql -u anawiesn -prPdPkVyeVTqdgwXn -h mysql.agh.edu.pl -P 3306 -e "USE anawiesn; LOAD DATA LOCAL INFILE 'IS.txt' INTO TABLE CUSTOMERS_${NUMERINDEKSU} FIELDS TERMINATED BY '|';"
#mysql -u anawiesn -prPdPkVyeVTqdgwXn -h mysql.agh.edu.pl -P 3306 -e "USE anawiesn; SELECT COUNT(*) FROM CUSTOMERS_${NUMERINDEKSU};"


echo "Moving file to subdirectory"
TIMESTAMP2=`date +%Y-%m-%d_%H-%M-%S`
rm IS.txt
mv "InternetSales_new_created.txt" PROCESSED/${TIMESTAMP2}_InternetSales_new.txt
if [ $? -ne 0 ];then
	echo "ERROR $? - Moving file to subdirectory "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Moving file - ERROR" >>PROCESSED/"$logs_file"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Moving file - SUCCESS" >>PROCESSED/"$logs_file"
fi
echo "Sending an email"

#wyśle email zawierający nst. raport: temat: CUSTOMERS LOAD -${TIMESTAMP},treść:
wszystkie_wiersze="Liczba pobranych wierszy= $all_file"
wiersze="Liczba poprawnych wierszy= $poprawne"
duplikaty="Liczba duplikatów w pliku wejściowym= $duplikats"
bledne="Ilość odrzuconych wierszy= $zle"
tab=`mysql -u $3 -h $5 -P $6 --silent -e "USE anawiesn; SELECT COUNT(*) FROM CUSTOMERS_${NUMERINDEKSU};"`
zaladowane="Ilość załadowanych danych $tab"

TIMESTAMP3=`date +%Y-%m-%d_%H-%M-%S`
#echo -e "$wszystkie_wiersze \n $wiersze \n $duplikaty \n $bledne \n $zaladowane" | mailx -s "CUSTOMERS LOAD - $TIMESTAMP3" $8

if [ $? -ne 0 ];then
	echo "ERROR $? - Sending email "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Sending email - ERROR" >>PROCESSED/"$logs_file"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Sending email - SUCCESS" >>PROCESSED/"$logs_file"
fi

mysql -u $3 -h $5 -P $6 --silent -e "USE anawiesn; UPDATE CUSTOMERS_${NUMERINDEKSU} SET $v8='`tr -dc A-Za-z0-9 </dev/urandom | head -c 10 ; echo ''`'" 

if [ $? -ne 0 ];then
	echo "ERROR $? - Updating var with random string "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Random string - ERROR" >>PROCESSED/"$logs_file"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Random string - SUCCESS" >>PROCESSED/"$logs_file"
fi

# THIS WORKS ONLY ON LOCAL DB AND WITH ACCESS TO WRITE
#mysql -u $3 -p$4 -h $5 -P $6 --silent -e "USE anawiesn;SELECT $v1, $v2, $v3, $v4, $v5, $v6, $v7, $v8 FROM CUSTOMERS_${NUMERINDEKSU} INTO OUTFILE './out.csv';

# THIS WORKS ALWAYS 
#mysql -u anawiesn -prPdPkVyeVTqdgwXn -h mysql.agh.edu.pl -P 3306 -e "USE anawiesn; SELECT * FROM CUSTOMERS_290923" > tosave.csv 2>/dev/null
mysql -u $3 -h $5 -P $6 --silent -e "USE anawiesn; SELECT * FROM CUSTOMERS_290923" > tosave.csv

if [ $? -ne 0 ];then
	echo "ERROR $? - Downlading data from db "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Creating csv - ERROR" >>PROCESSED/"$logs_file"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Creating cvs - SUCCESS" >>PROCESSED/"$logs_file"
fi

TIMESTAMP4=`date +%Y-%m-%d_%H-%M-%S`
sed -i 's/\t/,/g'  tosave.csv
ile=`wc -l < tosave.csv`
tar -cf CUSTOMERS_${NUMERINDEKSU}.tar tosave.csv 

if [ $? -ne 0 ];then
	echo "ERROR $? - Adding to archive "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Adding to archive - ERROR" >>PROCESSED/"$logs_file"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Adding to archive - SUCCESS" >>PROCESSED/"$logs_file"
fi

echo -e "Ilosc wierszy pliku= $ile, data wykonania pliku: $TIMESTAMP4" > tosend
#mailx -s "CUSTOMERS ARCHIVE" -a CUSTOMERS_${NUMERINDEKSU}.tar -a tosend $8
if [ $? -ne 0 ];then
	echo "ERROR $? - Sending email "
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Sending email - ERROR" >>PROCESSED/"$logs_file"
	exit 1
else
	T1=`date +%Y-%m-%d_%H-%M-%S`
 	echo "$T1 - Sending email - SUCCESS" >>PROCESSED/"$logs_file"
fi
rm tosend




