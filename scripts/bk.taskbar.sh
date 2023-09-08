#!/bin/bash

BASECMD=${1%%\ *}
PID=$(pgrep "$BASECMD")
if [ "$?" -eq "0" ]
then
	echo "It's on"
	pkill trayer 
	sleep 1
else
	echo "It's off"
	trayer  --monitor 0 --edge top --align center --SetDockType true --SetPartialStrut false --expand true --widthtype request --transparent true --tint 0x5b6268 --height 24 &
        sleep 1
fi

