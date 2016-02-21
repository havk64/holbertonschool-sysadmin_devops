#!/bin/bash
{ echo $2; $1;} &>/tmp/4-stdout_and_stderr;
cat /tmp/4-stdout_and_stderr;
