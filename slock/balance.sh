#!/usr/bin/env bash

FROM=$(cat ~/.slock/balance_start | cut -d' ' -f 1)
BEG_BAL=$(cat ~/.slock/balance_start | cut -d' ' -f 2)

num_days=0
total=0
(
	~/.slock/antime.sh | sed -u 1d | while read -r timestamp time on; do
		if [ $timestamp -lt $FROM ]; then
			B=$(echo "($total - $num_days*8*60*60 + $BEG_BAL)" | bc -l)
			echo $B
			break
		fi
		#echo $timestamp $(echo $time/3600 | bc -l)
		num_days=$(($num_days + 1))
		total=$(($total + $time))
	done
	echo 0
) | head -n 1
