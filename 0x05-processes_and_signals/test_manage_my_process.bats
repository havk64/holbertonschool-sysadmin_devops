#!/usr/bin/env bats
# Unit tests for task 10, process management

INIT='./10-manage_my_process'
PIDFILE='/var/run/my_process.pid'
TMPFILE='/tmp/my_process'
USAGE="Usage: manage_my_process {start|stop|restart}"

teardown() { run "$INIT" stop; }

feedback_msg()
{
	echo "manage_my_process $1"
}

@test "Show usage when no parameter is given" {
	run "$INIT"
	[ "$status" -eq 1 ]
	[ "$output" = "$USAGE" ]
}

@test "Show usage when # of parameter is greater than 1 or invalid" {
	[[ -z "${PID+x}" ]]
	run "$INIT" start stop
	[ "$status" -eq 1 ]
	[ "$output" = "$USAGE" ]
	run "$INIT" waaaat?
	[ "$status" -eq 1 ]
	[ "$output" = "$USAGE" ]
	run "$INIT" startt
	[ "$status" -eq 1 ]
	[ "$output" = "$USAGE" ]
}

@test "Starts and prints friendly msg" {
	run "$INIT" start
	[ "$status" -eq 0 ]
	[ "$output" = "$(feedback_msg 'started')" ]
	[ -e "$PIDFILE" ]
	[ -s "$PIDFILE" ]
	PID=$(head -1 "$PIDFILE")
	ps aux | grep -q "[^]]$PID"
	[[ $? ]]
}

@test "$TMPFILE was create and string is being added" {
	[ -e "$TMPFILE" ]
	run grep -q '^I am alive!$' "$TMPFILE"
	[ "$status" -eq 0 ]
}

@test "Stops when stop argument is given and deletes PIDFILE" {
	run "$INIT" stop
	[ "$status" -eq 0 ]
	[ "$output" = "$(feedback_msg 'stopped')" ]
	[[ ! -e $PIDFILE ]]
}

@test "Restarts when restart argument is given" {
	[[ ! -e $PIDFILE ]]
	run "$INIT" start
	PID=$(head -1 "$PIDFILE")
	[ -e "$PIDFILE" ]
	[ -s "$PIDFILE" ]
	run "$INIT" restart
	[ -e "$PIDFILE" ]
	[ -s "$PIDFILE" ]
	# It should be modified since last time read(head command above)
	[[ -N $PIDFILE ]]
	NEWPID=$(head -1 "$PIDFILE")
	[ "$status" -eq 0 ]
	[ "$output" = "$(feedback_msg 'restarted')" ]
	[[ "$PID" != "$NEWPID" ]]
}
