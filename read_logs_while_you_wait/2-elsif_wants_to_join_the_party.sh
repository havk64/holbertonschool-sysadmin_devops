#!/bin/bash
HEAD=0;
GET=0;
while read line
do
	if echo $line | grep -q "HEAD"
	then
		((HEAD++)) 
	elif echo $line | grep -q "GET"
	then
		((GET++))
	fi
done < $1;
printf "%d\n" $HEAD;
printf "%d\n" $GET;
