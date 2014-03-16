#!/bin/bash
#
# Extract envent files for a small region

# copy event file
cp `ls -1 $xmm_rpcdata/*MOS2*ImagingEvts.ds` ./mos2evts_barycen.ds

# Make barycentric correction on the clean event file
barycen table=mos2evts_barycen.ds:EVENTS

# Get the coordinates from the .reg file
cp $PWD/../src_evt.reg ./
while read LINE
do
    srcregion=$LINE
done < src_evt.reg
export srcregion
# export srcregion=circle(1000,2000,50)

# input file
export mos2table=mos2evts_barycen.ds

# output filenames
export fsrcname="mos2evts_src_0310keV.ds"
export fimgname="mos2evts_src_img_0310keV.ds"

#energy range
export emin=300
export emax=10000

# Extract an event file for the src+bkg region for single and double events
evselect --table=$mos2table --energycolumn='PI' \
    --keepfilteroutput=yes --withfilteredset=yes --filteredset=$fsrcname \
    --withimageset=yes --imageset=$fimgname --xcolumn='X' --ycolumn='Y' \
    --expression="#XMMEA_EM && (PI IN [$emin :$emax ]) && PATTERN <=12 && ((X,Y) IN $srcregion)"

# Show extracted image and region
ds9 $fimgname -zoom 2 -log -cmap heat -region load src_evt.reg
