#!/bin/bash

FILE='/tmp/permissions'
touch $FILE		# Creating the file.
sudo chown :staff $FILE # Changing the group of the file.
