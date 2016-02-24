#!/bin/bash
while read line
do
	if echo $line | grep -q "HEAD"
	then
		echo $line
	fi
done < $1;
