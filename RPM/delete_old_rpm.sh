#!/bin/bash

####
#
# quick script that takes all rpm in the current directory
# and delete the smaller version when several versions of 
# a same package exists
#
# Slow and not error-less
#
####
#
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
#
####

for file in *.rpm ; do
    regex='(.*)-[^-]+-[^-]+\.rpm'
    if [[ $file =~ $regex ]] ; then
        pkg_name=${BASH_REMATCH[1]}
        regex_same="$pkg_name-[^-]+-[^-]+\.rpm"
        for same_pkg in *.rpm ; do
            if [[ $same_pkg =~ $regex_same && `vercmp $file $same_pkg` -gt 0 ]] ; then
                rm $same_pkg
                echo $same_pkg removed
            fi
        done
    fi
done
