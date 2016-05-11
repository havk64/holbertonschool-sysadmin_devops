#!/bin/bash

FILE='/tmp/permissions'
touch $FILE		# Creating the file.
chmod 0755 $FILE	# Changing its permissions.
ls -l $FILE		# Listing the file, long format
