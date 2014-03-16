#!/bin/bash
#
# Discover a common time interval for the 3 epic cameras
#

export PNevents=`ls -1 $PWD/../rpcdata/*PN*ImagingEvts.ds*`
export MOS1events=`ls -1 $PWD/../rpcdata/*MOS1*ImagingEvts.ds*`
export MOS2events=`ls -1 $PWD/../rpcdata/*MOS2*ImagingEvts.ds*`

echo "PN times:"
ftkeypar $PNevents[EVENTS] TSTART chatter=3 
ftkeypar $PNevents[EVENTS] TSTOP chatter=3 
echo " "

echo "MOS1 times:"
ftkeypar $MOS1events[EVENTS] TSTART chatter=3 
ftkeypar $MOS1events[EVENTS] TSTOP chatter=3 
echo ""

echo "MOS2 times:"
ftkeypar $MOS2events[EVENTS] TSTART chatter=3 
ftkeypar $MOS2events[EVENTS] TSTOP chatter=3 
echo " "

echo "Enter common initial time for lightcurve analysis:"
read tstart
echo "Enter common final time for lightcurve analysis:"
read tstop
echo " "
