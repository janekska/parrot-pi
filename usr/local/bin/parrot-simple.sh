#!/bin/bash

BASEDIR=$(dirname $0)
#source sound files directory operational directory
SDIR=$BASEDIR/parrot
ODIR='/home/parrot'
#operational directory

#GPIO number
OUTPIO=27

# To do: check if GIPO is not in use 
echo $OUTPIO > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$OUTPIO/direction

# Release GPIO after use or on problem 
function cleanup()
{
    echo $OUTPIO > /sys/class/gpio/unexport
    exit 0
}

trap cleanup SIGINT

while true
do
    echo $ODIR
    rec $ODIR/buffer.wav silence 1 0.10 1% 1 5.0 1%

    echo "1" > /sys/class/gpio/gpio$OUTPIO/value
    sleep 1
    play $SDIR/begin.wav $ODIR/buffer.wav $SDIR/tail.wav
    #play $ODIR/voice/$DPATH/$DATE.wav
    echo "0" > /sys/class/gpio/gpio$OUTPIO/value

done

