#!/bin/bash
PRINT=$(ls -la /etc/ | grep pro);
printf '%s\n' "$PRINT";
