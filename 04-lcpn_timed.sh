#!/bin/bash
#
# Script to extract a barycentric corrected light curve for the PN camera
#
# It requires the src.reg and bkg.reg files obtained via SAO-ds9 software


##################### EDIT THIS BLOCk ###################################

# copy event file
cp `ls -1 $PWD/../../rpcdata/*PN*ImagingEvts.ds` ./pnevts_barycen.ds

# Export time limits if not already set
#export tstart=
#export tstop=

#----------------------------------------------------
# extract and export regions from the region files
# copy region files (saved in Physical format)

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
#-----------------------------------------------------

# correct to the solar barycenter
barycen table=pnevts_barycen.ds:EVENTS

# define bin size and energy range
export thebin=5
export emin=300
export emax=10000

# string to append at the filename
export strrange="0310keV_bin$thebin"

# export variables
export pntable=pnevts_barycen.ds

# define output filenames
export pnsrclc="PN_lc_src_"$strrange"_timed.ds"
export pnbkglc="PN_lc_bkg_"$strrange"_timed.ds"
export pnnetlc="PN_lc_net_"$strrange"_timed.ds"
export pnsrcimg="PN_src_img_"$strrange"_timed.ds"
export pnbkgimg="PN_bkg_img_"$strrange"_timed.ds"
export psimg="PN_lc_net_"$strrange"_timed.ps"

###################### END OF BLOCK #####################################

# Extract a lightcurve for the src+bkg region for single and double events
evselect --table=$pntable --energycolumn='PI' \
    --withrateset=yes --rateset=$pnsrclc \
    --timebinsize=$thebin --maketimecolumn=yes --makeratecolumn=yes \
    --withimageset=yes --imageset=$pnsrcimg --xcolumn='X' --ycolumn='Y' \
    --timemin=$tstart --timemax=$tstop \
    --expression="#XMMEA_EP && (PI IN [$emin :$emax]) && PATTERN <=4 && FLAG==0 && ((X,Y) IN $srcregion)"

# Extract a lightcurve for the bkg region for single and double events
evselect --table=$pntable --energycolumn='PI' \
    --withrateset=yes --rateset=$pnbkglc \
    --timebinsize=$thebin --maketimecolumn=yes --makeratecolumn=yes \
    --withimageset=yes --imageset=$pnbkgimg --xcolumn='X' --ycolumn='Y' \
    --timemin=$tstart --timemax=$tstop \    
    --expression="#XMMEA_EP && (PI IN [$emin :$emax]) && PATTERN <=4 && FLAG==0 && ((X,Y) IN $bkgregion)"

# Visualize images for double-check region selection
ds9 $pnsrcimg $pnbkgimg

# Apply corrections and creates the net lightcurve
epiclccorr --eventlist=$pntable --outset=$pnnetlc --srctslist=$pnsrclc \
    --applyabsolutecorrections=yes --withbkgset=yes --bkgtslist=$pnbkglc \

# Save the net lightcurve visualization
dsplot --table=$pnnetlc --withx=yes --withy=yes --x=TIME --y=RATE \
    --plotter="xmgrace -hardcopy -printfile $psimg"
