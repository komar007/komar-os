#!/bin/sh

HOST=$1

while true; do
        t0=$(date +%s)
        ssh "$HOST" -N || true
        t1=$(date +%s)
        t=$((t1-t0))
        if [ "$t" -lt 60 ]; then
                sleep 300
        else
                sleep 10
        fi
done
