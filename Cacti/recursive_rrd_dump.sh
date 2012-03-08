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


rrd_dir=/srv/http/cacti/rra
out_dir=/tmp/dump
concurrent_processes=8


dump_file(){
    if [[ $1 =~ $rrd_dir$2/(.*)\.rrd ]] ; then
        rrdtool dump $rrd_dir$2/${BASH_REMATCH[1]}.rrd $out_dir$2/${BASH_REMATCH[1]}.xml
    elif [[ -d $1 ]] ; then
        dump_dir $1
    else
        echo "Nothing to do with $1"
    fi
}

dump_dir() {
    if [ -d $1 ] ; then
        [[ $1 =~ $rrd_dir(.*) ]]
        wdir=${BASH_REMATCH[1]}
        mkdir -p $out_dir$wdir
        for file in $1/* ; do
            dump_file $file $wdir
        done
    else
        dump_file $1
    fi
}

for dir in $rrd_dir/* ; do
    dump_dir "$dir" &
    while (( $(jobs | wc -l) >= $concurrent_processes )); do
        sleep 0.1
        jobs > /dev/null
    done
done

wait

