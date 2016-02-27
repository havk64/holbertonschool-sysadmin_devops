#!/bin/bash

message=$1;
voice=$2;
server=$3;

case $voice in
    m )
        sex="Alex";;
    f )
        sex="Vicki";;
    x )
        sex="Luciana";;
esac

filename=$(echo $message | awk '{print $1}');
#echo $filename;

say -v "$sex" -o $filename.m4a "$message";
scp $filename.m4a admin@$server:/data/www/
printf "Listen to the message on http://%s\n", "$server";