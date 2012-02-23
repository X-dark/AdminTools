#!/bin/bash

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>

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
