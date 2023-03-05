#!/bin/bash

BASEDIR=$(dirname $0)
#source sound files directory
SDIR=$BASEDIR/parrot
#operational directory
ODIR='/home/parrot'
#GPIO number
OUTPIO=27

#Te vajadzētu pārbaudi, vai gpio jau nav aizņemti 
echo $OUTPIO > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$OUTPIO/direction

# Pārtraucot skripta darbību atbrīvojam GPIO 
function cleanup()
{
    echo $OUTPIO > /sys/class/gpio/unexport
    exit 0
}

trap cleanup SIGINT

while true
do
    rec $ODIR/buffer.wav silence 1 0.10 1% 1 5.0 1%

    DATE=`date +%Y%m%d%H%M%S`
    DPATH=`date +%Y/%m/%d/`
    mkdir -p $ODIR/spectro/$DPATH
    mkdir -p $ODIR/voice/$DPATH
    echo Renaming buffer file to $DATE
    sox $ODIR/buffer.wav -n spectrogram -x 300 -y 200 -z 100 -t $ODIR/$DATE.wav -o $ODIR/spectro/$DPATH/$DATE.png
    sox $ODIR/buffer.wav $ODIR/normbuffer.wav gain -n -2
    sox $ODIR/normbuffer.wav -n spectrogram -x 300 -y 200 -z 100 -t $ODIR/$DATE.norm.wav -o $ODIR/spectro/$DPATH/$DATE.norm.png
    mv $ODIR/normbuffer.wav $ODIR/voice/$DPATH/$DATE.wav

    echo "1" > /sys/class/gpio/gpio$OUTPIO/value
    sleep 1
    play $SDIR/begin.wav $ODIR/voice/$DPATH/$DATE.wav $SDIR/tail.wav
    #play $ODIR/voice/$DPATH/$DATE.wav
    echo "0" > /sys/class/gpio/gpio$OUTPIO/value

done

