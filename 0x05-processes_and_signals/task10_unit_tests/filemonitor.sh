#!/usr/bin/env bash
# This scripts start monitoring files or directories for any changes
# It makes use of inotifywait that is part of inotify-tools package.
# The output goes to stdout

EXEC='/usr/bin/inotifywait'

usage()
{
	printf '%s\n' "Usage: $(basename "$0") [ start|stop ] {filename|directory}"
	exit 1
}

checkDir()
{
	# Case the file to be monitored doesn't exist, waits for its creation
	while [[ ! -e $1 ]]; do sleep 0.5; done
	# Default format for directories
	local format='%T: %f %:e'
	# Case is a file instead change the output format
	[[ -f "$1" ]] && format='%T: %w %:e'
	echo "$format"
}


# Case the number of arguments is less then one or greater then 2, prints usage
[[ $# -lt 1 ]] || [[ $# -gt 2 ]] && usage

initMonitor() {
	echo "Waiting for file $(pwd)/$1"
	format=$(checkDir "$1")
	"$EXEC" -m --timefmt '%r' --format "$format" "$1" |
	while read -r change; do echo "$change"; done | grep -v 'utmp'
}

stopMonitor() {
	pkill -f "${EXEC:9}"
}

case "$1" in
	start)
		# Case second positional arg isn't given defaults to current dir
		DIR=${2-.}
		initMonitor "$DIR"
		;;
	stop)
		stopMonitor
		;;
	*)
		usage
esac
exit
