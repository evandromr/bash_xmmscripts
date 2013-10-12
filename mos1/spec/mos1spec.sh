#!/bin/bash
#
# Script to extract a energy spectrum for selected source region
# of the Clean events file of the MOS1 camera
#
# It requires the src.reg and bkg.reg files obtained via SAO-ds9 software
#

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
export mos1srcspc="MOS1_srcspc.ds"
export mos1srcimg="MOS1_srcimg.ds"
export mos1bkgspc="MOS1_bkgspc.ds"
export mos1bkgimg="MOS1_bkgimg.ds"
export mos1rmf="MOS1.rmf"
export mos1arf="MOS1.arf"
export mos1table=../MOS1_clean.ds

# Extracts a source+background spectrum
evselect --table=$mos1table:EVENTS \
    --withspectrumset=yes --spectrumset=$mos1srcspc --energycolumn='PI' \
    --withspecranges=yes --specchannelmax=11999 --specchannelmin=0 \
    --spectralbinsize=5 --withimageset=yes --imageset=$mos1srcimg \
    --xcolumn='X' --ycolumn='Y' \
    --expression='#XMMEA_EM && PATTERN<=12 && FLAG==0 && ((X,Y) IN '$srcregion')'

# Scale the areas of src and bkg regions used
backscale --spectrumset=$mos1srcspc \
    --withbadpixcorr=yes --badpixlocation=$mos1table 

# Extracts a background spectrum
evselect --table=$mos1table:EVENTS \
    --withspectrumset=yes --spectrumset=$mos1bkgspc --energycolumn='PI' \
    --withspecranges=yes --specchannelmax=11999 --specchannelmin=0 \
    --spectralbinsize=5 --withimageset=yes --imageset=$mos1bkgimg \
    --xcolumn='X' --ycolumn='Y' \
    --expression='#XMMEA_EM && PATTERN<=12 && FLAG==0 && ((X,Y) IN '$bkgregion')'

# Scale the are of the bkg region used
backscale --spectrumset=$mos1bkgspc \
    --withbadpixcorr=yes --badpixlocation=$mos1table

# Generates response matrix
rmfgen --rmfset=$mos1rmf --spectrumset=$mos1srcspc --format=var

# Generates ana Ancillary response file
arfgen --arfset=$mos1arf --spectrumset=$mos1srcspc \
    --withrmfset=yes --rmfset=$mos1rmf \
    --extendedsource=no --modelee=yes \
    --modelootcorr=yes --useodfatt=false \
    --withbadpixcorr=yes --badpixlocation=$mos1table

# Rebin the spectrum and link associated files (output:MOS1spec.pi)
# can be replaced by grppha tool from HEASOFT
specgroup --spectrumset=$mos1srcspc --mincounts=25 --oversample=3 \
    --backgndset=$mos1bkgspc --rmfset=$mos1rmf --arfset=$mos1arf \
    --groupedset=MOS1spec.pha
