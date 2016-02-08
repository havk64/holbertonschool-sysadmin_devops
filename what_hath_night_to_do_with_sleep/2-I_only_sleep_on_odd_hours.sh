#!/bin/bash
if [[ $(($1 % 2)) != 0 ]]; then
#if (($1 % 2)); then  <==== We can use this too, it works!
	echo "Sleep time!"	
else
	echo "Heh?"
fi

