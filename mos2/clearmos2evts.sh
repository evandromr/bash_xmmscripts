#!/bin/bash
#
# Script to clear the events file of hight background flare events
# For the MOS2 camera
#

# Select the events file for the MOS2 camera
export ImagingEvts=`ls -1 $xmm_rpcdata/*MOS2*ImagingEvts.ds*`

# Extract lightcurve for energy 10keV < E < 12keV and pattern='single'
evselect --table=$ImagingEvts:EVENTS \
    --withrateset=yes --rateset=MOS2_rate.ds \
    --maketimecolumn=yes --makeratecolumn=yes \
    --timebinsize=100 --timecolumn='TIME' \
    --expression='#XMMEA_EM && (PI > 10000) && (PATTERN==0)'

# Saves a plot of the lightcurve created
dsplot --table=MOS2_rate.ds:RATE --withx=yes --x=TIME --withy=yes --y=RATE \
    --plotter='xmgrace -hardcopy -printfile 'MOS2_rate.ps''

# Creates a GTI (good time interval) when RATE < 0.35
tabgtigen --table=MOS2_rate.ds --gtiset=MOS2_gti.ds --expression='RATE<=0.35'

# Creates a clean Events File with the events on the GTI
evselect --table=$ImagingEvts:EVENTS \
    --withfilteredset=yes --filteredset=MOS2_clean.ds --keepfilteroutput=yes \
    --expression='#XMMEA_EM && gti(MOS2_gti.ds, TIME) && (PI > 150)'

# Creates a lightcurve like PN_rate.ds but cleaned, for comparison
evselect --table=MOS2_clean.ds:EVENTS \
    --withrateset=yes --rateset=MOS2_rate_clean.ds \
    --maketimecolumn=yes --makeratecolumn=yes \
    --timecolumn='TIME' --timebinsize=100 \
    --expression='#XMMEA_EM && (PI > 10000) && (PATTERN==0)'

# Saves a plot of the cleaned lightcurve
dsplot --table=MOS2_rate_clean.ds:RATE \
    --withx=yes --x=TIME --withy=yes --y=RATE \
    --plotter='xmgrace -hardcopy -printfile 'MOS2_rate_clean.ps''

# Cratres before/after images for doubled-check visual analysis
evselect --table=$ImagingEvts --withimageset=true --imageset=MOS2_image.ds \
    --xcolumn=X --ycolumn=Y --ximagebinsize=80 --yimagebinsize=80 \
    --imagebinning=binSize \
    --expression='#XMMEA_EM && (PI>150 && PI<10000) && PATTERN<=12 && FLAG==0'

evselect --table=MOS2_clean.ds \
    --withimageset=true --imageset=MOS2_image_clean.ds \
    --xcolumn=X --ycolumn=Y --ximagebinsize=80 --yimagebinsize=80 \
    --imagebinning=binSize \
    --expression='#XMMEA_EM && (PI>150 && PI<10000) && PATTERN<=12 && FLAG==0'
