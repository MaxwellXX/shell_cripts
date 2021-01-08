#!/bin/bash 

# 把csv里的文件从第4行开始，按给定行数打散到小文件里， 并把title加回去
# https://stackoverflow.com/questions/20721120/how-to-split-csv-files-as-per-number-of-rows-specified
# mac上 sed -i 遇到点问题，所以用echo

function splitCsv() {
    HEADER=$(head -3 $1)
    #echo $HEADER
    if [ -n "$2" ]; then
        CHUNK=$2
    else 
        CHUNK=1000
    fi
    #tail -n +4 $1 
    tail -n +4 $1 | split -l $CHUNK - $1_split_
    for i in $1_split_*; do 
        echo -e "$HEADER\n$(cat $i)" > $i.csv
        rm -rf $i
        #sed -i  -e "1i$HEADER" "$i.csv"
    done
}

splitCsv $1 $2