#!/bin/bash
a=$(echo - | awk '{ print "'$1'"+"'$2'"/10}');
sleep $a
