#!/usr/bin/env bash
# This scripts start monitoring files or directories for any changes
# It makes use of inotifywait that is part of inotify-tools package.
# The output goes to stdout

EXEC='/usr/bin/inotifywait'

usage()
{
	printf '%s\n' "Usage: $(basename "$0") {filename|directory}"
	exit 1
}

checkDir()
{
	# Case the file to be monitored doesn't exist yet, waits for its creation
	[[ ! -e $1 ]] && echo "Waiting for file $(pwd)/$1"
	while [[ ! -e $1 ]]; do sleep 0.5; done
	# Default format for directories
	local format='%T: %f %:e'
	# Case is a file instead change the output format
	[[ -f "$1" ]] && format='%T: %w %:e'
	echo "$format"
}

# Case the number of arguments is not 1, prints usage
[[ $# -ne 1 ]] && usage

initMonitor() {
	format=$(checkDir "$1")
	 while read -r change; do
		 echo "$change"
	 done < <("$EXEC" -m --timefmt '%r' --format "$format" --exclude 'utmp' "$1")
}

DIR="${1:-.}"
initMonitor "$DIR"

exit
