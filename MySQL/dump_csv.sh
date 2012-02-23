#!/bin/bash

host='127.0.0.1'
database='cacti'
user='root'
outpath='/tmp/cacti'

read -s -p"$user DB password: " password
echo
tables=`mysql -u$user -p$password $database -h$host -N -B -e "show tables"`
if [ -z $tables ] ; then
    echo "Cannot fetch DB tables"
    exit 1
fi

#create output dir and change permission if needed
[ -d $outpath ] || mkdir $outpath
[ $(stat --printf='%a' $outpath) -ge 777 ] || chmod a+w $outpath

IFS='
'
success=true
for table in $tables ; do
    mysql -u$user -p$password -h$host $database -N -B -e "select * from $table into outfile '$outpath/$table.csv' fields terminated by ';' enclosed by '\"'"  || success=false
done

if $success ; then
    echo "All tables of $database database have been successfuly dumped to csv files in $outpath"
else
    echo "Errors encoutered while dumping $database database tables to $outpath"
fi
