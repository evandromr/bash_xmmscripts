#!/bin/bash
#
# Script to extract a energy spectrum for selected source region
# of the PN camera.
#
# It requires the src.reg and bkg.reg files obtained via SAO-ds9 software
#

export pntable=../PN_clean.ds
cp ../src.reg ./
cp ../bkg.reg ./

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
export pnsrcspc="PN_srcspc.ds"
export pnsrcimg="PN_srcimg.ds"
export pnbkgspc="PN_bkgspc.ds"
export pnbkgimg="PN_bkgimg.ds"
export pnrmf="PN.rmf"
export pnarf="PN.arf"

# Extracts a source+background spectrum
evselect --table=$pntable:EVENTS \
    --withspectrumset=yes --spectrumset=$pnsrcspc --energycolumn='PI' \
    --withspecranges=yes --specchannelmax=20479 --specchannelmin=0 \
    --spectralbinsize=5 --withimageset=yes --imageset=$pnsrcimg \
    --xcolumn='X' --ycolumn='Y' \
    --expression='#XMMEA_EP && PATTERN<=4 && FLAG==0 && ((X,Y) IN '$srcregion')'

# Scale the areas of src and bkg regions used
backscale --spectrumset=$pnsrcspc \
    --withbadpixcorr=yes --badpixlocation=$pntable 

# Extracts a background spectrum
evselect --table=$pntable:EVENTS \
    --withspectrumset=yes --spectrumset=$pnbkgspc --energycolumn='PI' \
    --withspecranges=yes --specchannelmax=20479 --specchannelmin=0 \
    --spectralbinsize=5 --withimageset=yes --imageset=$pnbkgimg \
    --xcolumn='X' --ycolumn='Y' \
    --expression='#XMMEA_EP && PATTERN<=4 && FLAG==0 && ((X,Y) IN '$bkgregion')'

# Scale the are of the bkg region used
backscale --spectrumset=$pnbkgspc \
    --withbadpixcorr=yes --badpixlocation=$pntable

# Generates response matrix
rmfgen --rmfset=$pnrmf --spectrumset=$pnsrcspc --format=var

# Generates ana Ancillary response file
arfgen --arfset=$pnarf --spectrumset=$pnsrcspc \
    --withrmfset=yes --rmfset=$pnrmf \
    --extendedsource=no --modelee=yes \
    --modelootcorr=yes --useodfatt=false \
    --withbadpixcorr=yes --badpixlocation=$pntable

# Rebin the spectrum and link associated files (output:PNspec.pi)
# can be replaced by grppha tool from HEASOFT
specgroup --spectrumset=$pnsrcspc --mincounts=25 --oversample=3 \
    --backgndset=$pnbkgspc --rmfset=$pnrmf --arfset=$pnarf \
    --groupedset=PNspec.pha
