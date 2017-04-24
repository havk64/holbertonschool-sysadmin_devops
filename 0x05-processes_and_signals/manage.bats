#!/usr/bin/env bats
# Unit tests for task 10, process management

EXECFILE='./10-manage_my_process'
USAGE="Usage: manage_my_process {start|stop|restart}"

init_msg()
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

