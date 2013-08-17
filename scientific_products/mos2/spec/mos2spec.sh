#!/bin/bash
#
# Script to extract a energy spectrum for selected source region
# of the Clean events file of the MOS2 camera
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
export mos2srcspc="MOS2_srcspc.ds"
export mos2srcimg="MOS2_srcimg.ds"
export mos2bkgspc="MOS2_bkgspc.ds"
export mos2bkgimg="MOS2_bkgimg.ds"
export mos2rmf="MOS2.rmf"
export mos2arf="MOS2.arf"
export mos2table=../MOS2_clean.ds

# Extracts a source+background spectrum
evselect --table=$mos2table:EVENTS \
    --withspectrumset=yes --spectrumset=$mos2srcspc --energycolumn='PI' \
    --withspecranges=yes --specchannelmax=11999 --specchannelmin=0 \
    --spectralbinsize=5 --withimageset=yes --imageset=$mos2srcimg \
    --xcolumn='X' --ycolumn='Y' \
    --expression='#XMMEA_EM && PATTERN<=12 && FLAG==0 && ((X,Y) IN '$srcregion')'

# Scale the areas of src and bkg regions used
backscale --spectrumset=$mos2srcspc \
    --withbadpixcorr=yes --badpixlocation=$mos2table 

# Extracts a background spectrum
evselect --table=$mos2table:EVENTS \
    --withspectrumset=yes --spectrumset=$mos2bkgspc --energycolumn='PI' \
    --withspecranges=yes --specchannelmax=11999 --specchannelmin=0 \
    --spectralbinsize=5 --withimageset=yes --imageset=$mos2bkgimg \
    --xcolumn='X' --ycolumn='Y' \
    --expression='#XMMEA_EM && PATTERN<=12 && FLAG==0 && ((X,Y) IN '$bkgregion')'

# Scale the are of the bkg region used
backscale --spectrumset=$mos2bkgspc \
    --withbadpixcorr=yes --badpixlocation=$mos2table

# Generates response matrix
rmfgen --rmfset=$mos2rmf --spectrumset=$mos2srcspc --format=var

# Generates ana Ancillary response file
arfgen --arfset=$mos2arf --spectrumset=$mos2srcspc \
    --withrmfset=yes --rmfset=$mos2rmf \
    --extendedsource=no --modelee=yes \
    --modelootcorr=yes --useodfatt=false \
    --withbadpixcorr=yes --badpixlocation=$mos2table

# Rebin the spectrum and link associated files (output:MOS2spec.pi)
# can be replaced by grppha tool from HEASOFT
specgroup --spectrumset=$mos2srcspc --mincounts=25 --oversample=3 \
    --backgndset=$mos2bkgspc --rmfset=$mos2rmf --arfset=$mos2arf \
    --groupedset=MOS2spec.pi
