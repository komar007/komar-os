#!/usr/bin/env bash

WORK_TIME=$((8 * 3600))
SHOULD_START="08:30:00"
MAXDIFF=$((5 * 60))
LEAVE_EXTRA=$((10 * 60))

function color_xmobar() {
	text=$1
	color=$2
	if [ -n "$color" ]; then
		echo "<fc=$color>$text</fc>"
	else
		echo "$text"
	fi
}

function low_mid_high() {
	value=$1
	low=$2
	high=$3
	low_out=$4
	mid_out=$5
	high_out=$6
	if [ $value -lt $low ]; then
		echo $low_out
	elif [ $value -lt $high ]; then
		echo $mid_out
	else
		echo $high_out
	fi
}

# (2d ago  yesterday  today)
WKTM_LOW=("#6a2119" "#93352a" "")
WKTM_MID=("#2a2c28" "#40423d" "#719a4b")
WKTM_HI=("#364924" "#456429" "#fb4934")

function balance() {
	B=$1
	COL=$2

	M=$(echo "scale=0;$B/60" | bc -l)
	S=+
	if [ $M -lt 0 ]; then
		S=-
		M=$((-$M))
	fi
	H=$(($M / 60))
	M=$(($M - $H * 60))
	text=$(printf "%c%d:%02d\n" "$S" "$H" "$M")
	color_xmobar "$text" "$COL"
}

num=0
if [ -x "$HOME/.slock/antime.sh" ]; then
	should_start=$(date -d "$SHOULD_START" +%s)
	"$HOME/.slock/antime.sh" | head -n 3 | tac | while read data; do
		time_start=$(echo "$data" | cut -d " " -f 1)
		day=$(echo "$data" | cut -d " " -f 2)
		start_diff=$(($time_start - $should_start))
		time_now=$(date +%s)

		color_time=$(low_mid_high $start_diff -$MAXDIFF $MAXDIFF "#719a4b" "" "#fb4934")
		color_day=$(low_mid_high $day $WORK_TIME $(($WORK_TIME + $LEAVE_EXTRA)) \
			"${WKTM_LOW[$num]}" "${WKTM_MID[$num]}" "${WKTM_HI[$num]}")

		time_start_h=$(date +%R -d @$time_start)
		day_h=$(TZ= date +%R -d @$day)
		time_part=$(color_xmobar "$time_start_h" $color_time)
		day_part=$(color_xmobar "$day_h" $color_day)
		if [ "$num" -ne 2 ]; then
			echo -n "$day_part "
		else

			bal=$($HOME/.slock/balance.sh)
			color_bal=$(low_mid_high $bal -600 600 "${WKTM_LOW[1]}" "${WKTM_MID[1]}" "${WKTM_HI[1]}")
			bal_text=$(balance "$bal" "$color_bal")
			echo -n "<fc=#cccccc><icon=enter.xbm/></fc> [$bal_text] $time_part ($day_part)"
		fi
		num=$(($num + 1))
	done
fi
