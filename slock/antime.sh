#!/usr/bin/env bash

last_lock1=""
last_lock2=""
prev_unlock=""
prev_lock=""
now=$(date +%s)
tac ~/.slock/slock_wrapper.log | while read timestamp action; do
	case "$action" in
		lock)
			lock=$timestamp
			if [ -n "$prev_lock" ]; then
				d=$(date -d @$lock +%D)
				fst_d=$(date -d @$prev_lock +%D)
				if [ "$d" != "$fst_d" ]; then
					last_lock1=$last_lock2
					last_lock2=$lock
				fi
			fi
			prev_lock=$lock
			;;
		unlock)
			unlock=$timestamp
			if [ -n "$prev_unlock" ]; then
				d=$(date -d @$unlock +%D)
				fst_d=$(date -d @$prev_unlock +%D)
				if [ "$d" != "$fst_d" ]; then
					lock_time=${last_lock1:-$now}
					time=$[$lock_time - $prev_unlock]
					echo $prev_unlock $time $sum_time
					sum_time=0
				fi
			fi
			p_lock=${prev_lock:-$now}
			period=$[$p_lock - $unlock]
			sum_time=$[$sum_time + $period]
			prev_unlock=$unlock
			;;
	esac
done
