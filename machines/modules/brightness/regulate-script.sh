IN_DEV="iio:device0"
OUT_DEV="amdgpu_bl1"

HI_IN=220
HI_OUT=85

LO_IN=6
LO_OUT=4

MIN_BR=3
USER_MAX_BR=256

GRADIENT_STEPS=10

ILLUM_FILE="/sys/bus/iio/devices/$IN_DEV/in_illuminance_raw"
BR_FILE="/sys/class/backlight/$OUT_DEV/brightness"
MAX_BR_FILE="/sys/class/backlight/$OUT_DEV/max_brightness"

while true; do
	A=$((HI_IN-LO_IN))
	I=$(cat $ILLUM_FILE)
	MAX_BR=$(cat $MAX_BR_FILE)
	BR=$(((I-LO_IN)*(HI_OUT-LO_OUT)/A+LO_OUT))
	BR=$((BR>MAX_BR?MAX_BR:BR))
	BR=$((BR>USER_MAX_BR?USER_MAX_BR:BR))
	BR=$((BR<MIN_BR?MIN_BR:BR))

	PREV_BR=$(cat "$BR_FILE")
	DIFF=$((BR-PREV_BR))
	ADIFF=$((DIFF<0?-DIFF:DIFF))
	STEPS=$((ADIFF>GRADIENT_STEPS?GRADIENT_STEPS:ADIFF))
	if [ "$STEPS" -eq 0 ]; then
		sleep 1
		continue
	fi
	GRADIENT_T=$(echo "1/$STEPS" | bc -l)
	INCR=$((DIFF/STEPS))
	if [ "$INCR" -ne 0 ]; then
		for br in $(seq "$PREV_BR" "$INCR" "$BR"); do
			echo "$br" > "$BR_FILE"
			sleep "$GRADIENT_T"
		done
	else
		echo "$BR" > "$BR_FILE"
		sleep 1
	fi
done
