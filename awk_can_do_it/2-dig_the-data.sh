#!/bin/bash
#cat $1 | awk '{ print $1 " " $9}';
awk '{print $1,$9}' $1 | sort | uniq -c | sort ; 
