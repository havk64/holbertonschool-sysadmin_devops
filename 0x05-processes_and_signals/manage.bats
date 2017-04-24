#!/usr/bin/env bats
# Unit tests for task 10, process management

EXECFILE='./10-manage_my_process'
USAGE="Usage: manage_my_process {start|stop|restart}"

feedback_msg()
{
	echo "manage_my_process $1"
}

@test "Show usage when no parameter is given" {
	run "$EXECFILE"
	[ "$status" -eq 1 ]
	[ "$output" = "$USAGE" ]
}

@test "Show usage when # of parameter is greater than 1 or invalid" {
	run "$EXECFILE" start stop
	[ "$status" -eq 1 ]
	[ "$output" = "$USAGE" ]
	run "$EXECFILE" waaaat?
	[ "$status" -eq 1 ]
	[ "$output" = "$USAGE" ]
	run "$EXECFILE" startt
	[ "$status" -eq 1 ]
	[ "$output" = "$USAGE" ]
}

@test "Starts and prints friendly msg" {
	run "$EXECFILE" start
	[ "$status" -eq 0 ]
	[ "$output" = "$(feedback_msg 'started')" ]
}

@test "Creates the PID file" {
	[ -e "$PIDFILE" ]
}


@test "$TMPFILE was create" {
	[ -e "$TMPFILE" ]
}

@test "Stops when argument stop is given" {
	run "$EXECFILE" stop
	[ "$status" -eq 0 ]
	[ "$output" = "$(feedback_msg 'stopped')" ]
}
