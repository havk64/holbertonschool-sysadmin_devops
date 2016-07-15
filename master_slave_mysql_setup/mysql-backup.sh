# ===---------------------------------------------------------------------------===
#       Automatic MySQL backups with shell script
#
#       by Alexandro de Oliveira, for Holberton School
# ===---------------------------------------------------------------------------===

BKFILE='/tmp/backup.sql'
TARGZ=$(date +%d-%m-%Y).tar.gz
PASSWD='W7/}yyKw3rPWBqk'

# Lock database and make it read only:
mysql -u root -p$PASSWD --execute="FLUSH TABLES WITH READ LOCK; SET GLOBAL read_only = 1;"

# Back it up:
mysqldump -u root -p$PASSWD --all-databases > $BKFILE

# Archive it with tar and gzip:
tar -czvf $TARGZ $BKFILE

# Remove the backup file:
rm -f $BKFILE

# Unlock the database:
mysql -u root -p$PASSWD --execute="SET GLOBAL read_only = 0; UNLOCK TABLES;"

# Transfer the backupfile to AWS S3 Bucket:
# Waiting AWS Educate account confirmation...

# Remove the backup file locally:
rm -f $TARGZ
