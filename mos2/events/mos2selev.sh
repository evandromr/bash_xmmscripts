#!/bin/bash

# Extract an event file for the src+bkg region for single and double events
evselect --table=$mos2table --energycolumn='PI' \
    --keepfilteroutput=yes --withfilteredset=yes --filteredset=$fsrcname \
    --withimageset=yes --imageset=$fimgname --xcolumn='X' --ycolumn='Y' \
    --expression="#XMMEA_EM && (PI IN [$emin :$emax ]) && PATTERN <=12 && ((X,Y) IN $srcregion)"

# Show extracted image and region
ds9 $fimgname -zoom 2 -log -cmap heat -region load src_evt.reg
