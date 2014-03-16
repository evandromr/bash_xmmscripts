#!/bin/bash
#
# Extract event files for a small region

# copy event file
cp `ls -1 $PWD/../rpcdata/*PN*ImagingEvts.ds` ./pnevts_barycen.ds

# Make barycentric correction on the clean event file
barycen table=pnevts_barycen.ds:EVENTS

# Get the coordinates from the .reg file
cp $PWD/../src_evt.reg ./
while read LINE
do
    srcregion=$LINE
done < src_evt.reg
export srcregion
# export srcregion=circle(1000,2000,50)

#input file
export pntable=pnevts_barycen.ds

# output filenames
export fsrcname="pnevts_src_0310keV.ds"
export fimgname="pnevts_src_img_0310keV.ds"

# energy range
export emin=300
export emax=10000

# Extract an event file for the src+bkg region for single and double events
evselect --table=$pntable --energycolumn='PI' \
    --keepfilteroutput=yes --withfilteredset=yes --filteredset=$fsrcname \
    --withimageset=yes --imageset=$fimgname --xcolumn='X' --ycolumn='Y' \
    --expression="#XMMEA_EP && (PI IN [$emin :$emax ]) && PATTERN <=4 && FLAG==0 && ((X,Y) IN $srcregion)"

# Show extracted image and region
ds9 $fimgname -zoom 2 -log -cmap heat -region load src_evt.reg
