#!/bin/bash

FILE='/tmp/permissions'
touch $FILE		# Creating the file
sudo chown nobody $FILE # Changing the owner to "nobody", using sudo.
