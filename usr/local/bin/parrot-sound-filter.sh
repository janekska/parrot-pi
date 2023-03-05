#!/bin/bash

BASEDIR=$(dirname $0)
#source sound files directory
SDIR=$BASEDIR/parrot
#operational directory
ODIR='/home/parrot'

#GPIO number
OUTPIO=27
 
# Todo: check if GPIO isn't used already 
echo $OUTPIO > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$OUTPIO/direction

# Relase GPIO after usage 
function cleanup()
{
    echo $OUTPIO > /sys/class/gpio/unexport
    exit 0
}

trap cleanup SIGINT

while true
do
    echo Waiting for sound ...
    rec $ODIR/buffer.wav silence 1 0.10 1% 1 5.0 1%

    # Get sound sample
    # (should be created for each setup... ?)
    sox $ODIR/buffer.wav $ODIR/noise-audio.wav trim 0 0.900

    # Geting noise profile
    sox $ODIR/noise-audio.wav -n noiseprof $ODIR/noise.prof

    # Cleaning noise
    sox $ODIR/buffer.wav $ODIR/buffer-clean.wav noisered $ODIR/noise.prof 0.21

    DATE=`date +%Y%m%d%H%M%S`
    DPATH=`date +%Y/%m/%d/`
    mkdir -p $ODIR/spectro/$DPATH
    mkdir -p $ODIR/voice/$DPATH
    echo Renaming buffer file to $DATE
    mv $ODIR/buffer-clean.wav $ODIR/voice/$DPATH/$DATE.wav

    echo "1" > /sys/class/gpio/gpio$OUTPIO/value
    sleep 1

    play $ODIR/voice/$DPATH/$DATE.wav
    echo "0" > /sys/class/gpio/gpio$OUTPIO/value

done

