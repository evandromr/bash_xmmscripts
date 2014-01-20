#!/bin/bash
#
# Script to extract a barycentric corrected light curve for the PN camera
#
# It requires the src.reg and bkg.reg files obtained via SAO-ds9 software

export pnsrclc="PN_lc_src_"$strrange"_timed.ds"
export pnbkglc="PN_lc_bkg_"$strrange"_timed.ds"
export pnnetlc="PN_lc_net_"$strrange"_timed.ds"
export pnsrcimg="PN_src_img_"$strrange"_timed.ds"
export pnbkgimg="PN_bkg_img_"$strrange"_timed.ds"
export psimg="PN_lc_net_"$strrange"_timed.ps"

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
#ds9 $pnsrcimg $pnbkgimg

# Apply corrections and creates the net lightcurve
epiclccorr --eventlist=$pntable --outset=$pnnetlc --srctslist=$pnsrclc \
    --applyabsolutecorrections=yes --withbkgset=yes --bkgtslist=$pnbkglc \

# Save the net lightcurve visualization
dsplot --table=$pnnetlc --withx=yes --withy=yes --x=TIME --y=RATE \
    --plotter="xmgrace -hardcopy -printfile $psimg"
