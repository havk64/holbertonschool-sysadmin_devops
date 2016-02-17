#!/bin/bash
printf '%s\n' "$(cat list | grep l | sort -u)";
