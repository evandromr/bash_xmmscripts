#!/bin/bash
#
# Script to extract a barycentric corrected light curve for the MOS2 camera
#
# It requires the src.reg and bkg.reg files obtained via SAO-ds9 software

######################## EDIT THIS BLOCK ###############################

# copy event file
cp `ls -1 $PWD/../rpcdata/*MOS2*ImagingEvts.ds` ./mos2evts_barycen.ds

# Export time limits if not already set
#export tstart=
#export tstop=

#-------------------------------------------------------
# source and background regions

cp $PWD/../src.reg ./
cp $PWD/../bkg.reg ./
while read LINE
do
    srcregion=$LINE
done < src.reg

while read LINE
do
    bkgregion=$LINE
done < bkg.reg

export srcregion
export bkgregion

# alternative input:
#export srcregion=circle(10000,20000,200)
#export bkgregion=circle(15000,25000,200)
#---------------------------------------------------------

# Make barycentric correction on the clean event file
barycen table=mos2evts_barycen.ds:EVENTS

#binsize and energy range
export thebin=5
export emin=300
export emax=10000

# string to apend at the output filename
export strrange="0310keV_bin$thebin"

export mos2table=mos2evts_barycen.ds

# define outpuf filenames
export mos2srclc="MOS2_lc_src_"$strrange".ds"
export mos2bkglc="MOS2_lc_bkg_"$strrange".ds"
export mos2netlc="MOS2_lc_net_"$strrange".ds"
export mos2srcimg="MOS2_src_img_"$strrange".ds"
export mos2bkgimg="MOS2_bkg_img_"$strrange".ds"
export psimg="MOS2_lc_net_"$strrange".ps"

######################## END OF BLOCK ##################################

# Extract a lightcurve for the src+bkg region for single and double events
evselect --table=$mos2table --energycolumn='PI' \
    --withrateset=yes --rateset=$mos2srclc \
    --timebinsize=$thebin --maketimecolumn=yes --makeratecolumn=yes \
    --withimageset=yes --imageset=$mos2srcimg --xcolumn='X' --ycolumn='Y' \
    --timemin=$tstart --timemax=$tstop \
    --expression="#XMMEA_EM && (PI IN [$emin :$emax]) && PATTERN <=12 && FLAG==0 && ((X,Y) IN $srcregion)"

# Extract a lightcurve for the bkg region for single and double events
evselect --table=$mos2table --energycolumn='PI' \
    --withrateset=yes --rateset=$mos2bkglc \
    --timebinsize=$thebin --maketimecolumn=yes --makeratecolumn=yes \
    --withimageset=yes --imageset=$mos2bkgimg --xcolumn='X' --ycolumn='Y' \
    --timemin=$tstart --timemax=$tstop \
    --expression="#XMMEA_EM && (PI IN [$emin :$emax]) && PATTERN <=12 && FLAG==0 && ((X,Y) IN $bkgregion)"

# Visualize images for double-check region selection
ds9 $mos2srcimg $mos2bkgimg

# Apply corrections and creates the net lightcurve
epiclccorr --eventlist=$mos2table --outset=$mos2netlc --srctslist=$mos2srclc \
    --applyabsolutecorrections=yes --withbkgset=yes --bkgtslist=$mos2bkglc \

# Save the net lightcurve visualization
dsplot --table=$mos2netlc --withx=yes --withy=yes --x=TIME --y=RATE \
    --plotter="xmgrace -hardcopy -printfile $psimg"
