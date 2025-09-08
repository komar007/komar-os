#!/usr/bin/env bash

if [ $# -ne 1 ]; then
	echo "usage: $0 start_balance"
	exit 1
fi
echo $(date +%s) $1 > ~/.slock/balance_start
