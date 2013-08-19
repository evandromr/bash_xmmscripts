#!/bin/bash
#
# Script to clear the events file of hight background flare events
# For the MOS1 camera
#

# Select the events file for the MOS1 camera
export ImagingEvts=`ls -1 $xmm_rpcdata/*MOS1*ImagingEvts.ds*`

# Extract lightcurve for energy 10keV < E < 12keV and pattern='single'
evselect --table=$ImagingEvts:EVENTS \
    --withrateset=yes --rateset=MOS1_rate.ds \
    --maketimecolumn=yes --makeratecolumn=yes \
    --timebinsize=100 --timecolumn='TIME' \
    --expression='#XMMEA_EM && (PI > 10000) && (PATTERN==0)'

# Saves a plot of the lightcurve created
dsplot --table=MOS1_rate.ds:RATE --withx=yes --x=TIME --withy=yes --y=RATE \
    --plotter='xmgrace -hardcopy -printfile 'MOS1_rate.ps''

# Creates a GTI (good time interval) when RATE < 0.4
tabgtigen --table=MOS1_rate.ds --gtiset=MOS1_gti.ds --expression='RATE<=0.35'

# Creates a clean Events File with the events on the GTI
evselect --table=$ImagingEvts:EVENTS \
    --withfilteredset=yes --filteredset=MOS1_clean.ds --keepfilteroutput=yes \
    --expression='#XMMEA_EM && gti(MOS1_gti.ds, TIME) && (PI > 150)'

# Creates a lightcurve like PN_rate.ds but cleaned, for comparison
evselect --table=MOS1_clean.ds:EVENTS \
    --withrateset=yes --rateset=MOS1_rate_clean.ds \
    --maketimecolumn=yes --makeratecolumn=yes \
    --timecolumn='TIME' --timebinsize=100 \
    --expression='#XMMEA_EM && (PI > 10000) && (PATTERN==0)'

# Saves a plot of the cleaned lightcurve
dsplot --table=MOS1_rate_clean.ds:RATE \
    --withx=yes --x=TIME --withy=yes --y=RATE \
    --plotter='xmgrace -hardcopy -printfile 'MOS1_rate_clean.ps''

# Cratres before/after images for doubled-check visual analysis
evselect --table=$ImagingEvts --withimageset=true --imageset=MOS1_image.ds \
    --xcolumn=X --ycolumn=Y --ximagebinsize=80 --yimagebinsize=80 \
    --imagebinning=binSize \
    --expression='#XMMEA_EM && (PI>150 && PI<10000) && PATTERN<=4 && FLAG==0'

evselect --table=MOS1_clean.ds \
    --withimageset=true --imageset=MOS1_image_clean.ds \
    --xcolumn=X --ycolumn=Y --ximagebinsize=80 --yimagebinsize=80 \
    --imagebinning=binSize \
    --expression='#XMMEA_EM && (PI>150 && PI<10000) && PATTERN<=4 && FLAG==0'
