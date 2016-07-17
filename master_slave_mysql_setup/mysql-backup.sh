#!/bin/bash

# ===---------------------------------------------------------------------------===
#       Automatic MySQL daily backups
#	This script creates a backup from mySQL database, compress it and upload
#	it to an Amazon S3 bucket using just Shell and Curl.
#
#       by Alexandro de Oliveira, for Holberton School
# ===---------------------------------------------------------------------------===


# AWS Authentication info
BUCKET='holberton'
KEY="xxx"
SECRET="xxx"
HOST="$BUCKET.s3.amazonaws.com"

TPATH='/tmp'
TMP="$TPATH/backup.sql"
FILE=$(date +%d-%m-%Y).tar.gz
NOW=$(date +"%a, %d %b %Y %T %z")	# $(date -R) on Linux works the same.
TYPE='application/tar+gzip'
STRING="PUT\n\n$TYPE\n$NOW\n/$BUCKET/$FILE"
SIGNATURE=$(echo -en "$STRING" | openssl sha1 -hmac "$SECRET" -binary | base64)
PASSWD='xxx' 		# MySQL password

# Lock database and make it read only:
mysql -u root -p$PASSWD --execute="FLUSH TABLES WITH READ LOCK; SET GLOBAL read_only = 1;"

# Back it up:
mysqldump -u root -p$PASSWD --all-databases > $TMP

# Unlock the database:
mysql -u root -p$PASSWD --execute="SET GLOBAL read_only = 0; UNLOCK TABLES;"

# Archive it with tar and gzip:
tar -czvf "$TPATH/$FILE" $TMP

# Remove the temp file:
rm -f $TMP

# Sending the file to S3 Bucket with a PUT request:
curl -L -X PUT -T "$TPATH/$FILE" \
	-H "Host: $HOST" \
	-H "Date: $NOW" \
	-H "Content-Type: $TYPE" \
	-H "Authorization: AWS $KEY:$SIGNATURE" \
	https://"$HOST/$FILE"

# Transfer the backupfile to AWS S3 Bucket:
# Waiting AWS Educate account confirmation...

# Remove the backup file locally:
rm -f "$TPATH/$FILE"
