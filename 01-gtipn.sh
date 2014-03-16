#!/bin/bash
#
# Script to clear the events file of hight background flare events
# For the PN camera
#

export PNevents=`ls -1 $PWD/../rpcdata/*PN*ImagingEvts.ds*`

# Extract lightcurve for energy 10keV < E < 12keV and pattern='single'
evselect --table=$PNevents:EVENTS \
    --withrateset=yes --rateset=PN_rate.ds \
    --maketimecolumn=yes --makeratecolumn=yes \
    --timebinsize=100 --timecolumn='TIME' \
    --expression='#XMMEA_EP && (PI > 10000 && PI < 12000) && (PATTERN==0)'

# Saves a plot of the lightcurve created
dsplot --table=PN_rate.ds:RATE --withx=yes --x=TIME --withy=yes --y=RATE \
    --plotter='xmgrace -hardcopy -printfile 'PN_rate.ps''

# Creates a GTI (good time interval) when RATE < 0.4
tabgtigen --table=PN_rate.ds --gtiset=PN_gti.ds --expression='RATE<=0.4'

# Creates a clean Events File with the events on the GTI
evselect --table=$PNevents:EVENTS \
    --withfilteredset=yes --filteredset=PN_clean.ds --keepfilteroutput=yes \
    --expression='#XMMEA_EP && gti(PN_gti.ds, TIME) && (PI > 150)'

# Creates a lightcurve like PN_rate.ds but cleaned, for comparison
evselect --table=PN_clean.ds:EVENTS \
    --withrateset=yes --rateset=PN_rate_clean.ds \
    --maketimecolumn=yes --makeratecolumn=yes \
    --timecolumn='TIME' --timebinsize=100 \
    --expression='#XMMEA_EP && (PI > 10000 && PI < 12000) && (PATTERN==0)'

# Saves a plot of the cleaned lightcurve
dsplot --table=PN_rate_clean.ds:RATE --withx=yes --x=TIME --withy=yes --y=RATE \
    --plotter='xmgrace -hardcopy -printfile 'PN_rate_clean.ps''

# Creates before/after images for doubled-check visual analysis
evselect --table=$PNevents --withimageset=true --imageset=PN_image.ds \
    --xcolumn=X --ycolumn=Y --ximagebinsize=80 --yimagebinsize=80 \
    --imagebinning=binSize \
    --expression='#XMMEA_EP && (PI>150 && PI<12000) && PATTERN<=4 && FLAG==0'

evselect --table=PN_clean.ds --withimageset=true --imageset=PN_image_clean.ds \
    --xcolumn=X --ycolumn=Y --ximagebinsize=80 --yimagebinsize=80 \
    --imagebinning=binSize \
    --expression='#XMMEA_EP && (PI>150 && PI<12000) && PATTERN<=4 && FLAG==0'
