#!/bin/bash
printf '%s\n' "$(cat list | grep o | sort)";
