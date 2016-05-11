#!/bin/bash

FILE='/tmp/permissions'
touch $FILE		# Creating the file.
chmod ago+rw $FILE	# Read and write permissions to admin, group and others.
