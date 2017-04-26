#!/usr/bin/env bats
# Unit tests for task 10, process management

INIT='../10-manage_my_process'
DAEMON=manage_my_process
PIDFILE='/var/run/my_process.pid'
TMPFILE='/tmp/my_process'
USAGE="Usage: $DAEMON {start|stop|restart}"

teardown() {
	run "$INIT" stop
	dbg_save_source "./$DAEMON-test.src"
}

# Save a copy of the preprocessed test file.
#
# Globals:
#   BATS_TEST_SOURCE
# Arguments:
#   $1 - [=./$DAEMON.$$.src] destination file/directory
# Returns:
#   none
dbg_save_source() {
	local -r dest="${1:-.}"
	cp --reflink=auto "$BATS_TEST_SOURCE" "$dest"
}

feedback_msg()
{
	echo "$DAEMON $1"
}

@test "Show usage when no parameter is given" {
	run "$INIT"
	# It exis status should be 1
	[[ $status -eq 1 ]]
	# It should show usage
	[[ $output = $USAGE ]]
}

@test "Show usage when # of parameter is greater than 1 or invalid" {
	# It should show usage when given wrong parameters
	run "$INIT" start stop
	[[ $status -eq 1 ]]
	[[ $output = $USAGE ]]
	run "$INIT" waaaat?
	[[ $status -eq 1 ]]
	[[ $output = $USAGE ]]
	run "$INIT" startt
	[[ $status -eq 1 ]]
	[[ $output = $USAGE ]]
}

@test "Starts and prints friendly msg" {
	run "$INIT" start
	[[ $status -eq 0 ]]
	# It should output the start message
	[[ $output = $(feedback_msg 'started') ]]
	# It should create PID file(not empty)
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	# The process id should be the same for the file and process
	let "PID = $(head -1 "$PIDFILE")"
	ps aux | grep -q "[^]]$PID"
	[[ $? ]]
}

@test "$TMPFILE was create and string is being added" {
	# It should create the tmp file
	[[ -e $TMPFILE ]]
	# Its content should match requirements
	run grep -q '^I am alive!$' "$TMPFILE"
	[[ $status -eq 0 ]]
}

@test "Stops when stop argument is given and deletes PIDFILE" {
	run "$INIT" stop
	[[ $status -eq 0 ]]
	# It should output the stop message
	[[ $output = $(feedback_msg 'stopped') ]]
	# It should delete the PID file
	[[ ! -e $PIDFILE ]]
}

@test "Restarts when restart argument is given" {
	# After each test the process should stop and remove pid file(teardown)
	[[ ! -e $PIDFILE ]]
	# Start the process before test the restart function
	run "$INIT" start
	# Get the PID before restart
	let "PID = $(head -1 "$PIDFILE")"
	# Check that the PID file was created
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run "$INIT" restart
	[[ $status -eq 0 ]]
	# It should output the restart message
	[[ $output = $(feedback_msg 'restarted') ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	# It should show up as modified since last time read(head command above)
	[[ -N $PIDFILE ]]
	# Compare the new PID with the last
	let "NEWPID = $(head -1 "$PIDFILE")"
	[[ $PID != $NEWPID ]]
}
