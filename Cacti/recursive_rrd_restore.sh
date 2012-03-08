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


xml_dir=/tmp/dump
out_dir=/tmp/rrd
concurrent_processes=8


restore_file(){
    if [[ $1 =~ $xml_dir$2/(.*)\.xml ]] ; then
        rrdtool restore $xml_dir$2/${BASH_REMATCH[1]}.xml $out_dir$2/${BASH_REMATCH[1]}.rrd
    elif [[ -d $1 ]] ; then
        restore_dir $1
    else
        echo "Nothing to do with $1"
    fi
}

restore_dir() {
    if [ -d $1 ] ; then
        [[ $1 =~ $xml_dir(.*) ]]
        wdir=${BASH_REMATCH[1]}
        mkdir -p $out_dir$wdir
        for file in $1/* ; do
            restore_file $file $wdir
        done
    else
        restore_file $1
    fi
}

for dir in $xml_dir/* ; do
    restore_dir "$dir" &
    while (( $(jobs | wc -l) >= $concurrent_processes )); do
        sleep 0.1
        jobs > /dev/null
    done
done

wait

