#!/usr/bin/env bats
# Kind of stress test to be sure the process management behavior is consistent
# across consecutive calls

INIT='../10-manage_my_process'
DAEMON='manage_my_process'
PIDFILE='/var/run/my_process.pid'

teardown() {
  dbg_save_source './bats-test.src'
}

# Save a copy of the preprocessed test file.
#
# Globals:
#   BATS_TEST_SOURCE
# Arguments:
#   $1 - [=./bats.$$.src] destination file/directory
# Returns:
#   none
dbg_save_source() {
  local -r dest="${1:-.}"
  cp --reflink=auto "$BATS_TEST_SOURCE" "$dest"
}

@test "Starts and stops the daemon checking pid file creation/deletion" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT stop
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON stopped" ]]
	[[ ! -e $PIDFILE ]]
}

@test "Starts and stops the daemon checking pid file creation/deletion" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT stop
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON stopped" ]]
	[[ ! -e $PIDFILE ]]
}

@test "Starts and stops the daemon checking pid file creation/deletion" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT stop
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON stopped" ]]
	[[ ! -e $PIDFILE ]]
}

@test "Starts and stops the daemon checking pid file creation/deletion" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT stop
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON stopped" ]]
	[[ ! -e $PIDFILE ]]
}


@test "Starts and stops the daemon checking pid file creation/deletion" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT stop
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON stopped" ]]
	[[ ! -e $PIDFILE ]]
}

@test "Starts and stops the daemon checking pid file creation/deletion" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT stop
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON stopped" ]]
	[[ ! -e $PIDFILE ]]
}

@test "Starts and stops the daemon checking pid file creation/deletion" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT stop
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON stopped" ]]
	[[ ! -e $PIDFILE ]]
}

@test "Starts and stops the daemon checking pid file creation/deletion" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT stop
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON stopped" ]]
	[[ ! -e $PIDFILE ]]
}

@test "Restarts the daemon checking pid file creation/deletion" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT restart
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON restarted" ]]
	[[ -e $PIDFILE ]]
	run $INIT restart
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON restarted" ]]
	[[ -e $PIDFILE ]]
	run $INIT restart
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON restarted" ]]
	[[ -e $PIDFILE ]]
	run $INIT restart
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON restarted" ]]
	[[ -e $PIDFILE ]]
	run $INIT restart
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON restarted" ]]
	[[ -e $PIDFILE ]]
	run $INIT restart
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON restarted" ]]
	[[ -e $PIDFILE ]]
	run $INIT restart
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON restarted" ]]
	[[ -e $PIDFILE ]]
}
 
@test "Stops the daemon" {
	run $INIT start
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON started" ]]
	[[ -e $PIDFILE ]]
	[[ -s $PIDFILE ]]
	run $INIT stop
	[[ $status -eq 0 ]]
	[[ $output = "$DAEMON stopped" ]]
	[[ ! -e $PIDFILE ]]
}
