#!/bin/bash

FILE='/tmp/permissions'
umask 0022 		# Using umask to change modify permissions of touch created file
if [ -f $FILE ];	# If file exists...
then
	rm $FILE	# Delete/remove it.
fi
touch $FILE		# Creating file with permissions 0644, because of umask 0022.
ls -l $FILE 		# Listing file to stdin, long format to show permissions.

