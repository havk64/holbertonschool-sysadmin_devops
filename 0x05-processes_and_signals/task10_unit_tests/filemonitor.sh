#!/usr/bin/env bash
# This scripts makes use of inotifywait that is part of inotify-tools package

EXEC='/usr/bin/inotifywait'

usage()
{
	printf '%s\n' "Usage: $(basename "$0") [ start|stop ] {filename|directory}"
	exit 1
}

[[ $# -lt 1 ]] || [[ $# -gt 2 ]] && usage

initMonitor() {
	echo "Waiting for file $(pwd)/$DIR"
	while [[ ! -e $DIR ]]; do sleep 0.5; done
	"$EXEC" -m --timefmt '%r' --format '%T: %f %:e' "$DIR" |
	while read -r change; do echo "$change"; done
}

stopMonitor() {
	pkill -f "${EXEC:9}"
}

case "$1" in
	start)
		DIR=${2-.}
		initMonitor "$DIR"
		;;
	stop)
		stopMonitor
		;;
	*)
		usage
esac
