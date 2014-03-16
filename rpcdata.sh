#!/bin/sh
#
# Script to reprocess observation data files
#

#Point to Raw Observation Data directory
export SAS_ODF=/home/evandro/xmm/obs/hd000000/2000jan01/odf

# Optional: copy the regions.reg file from the pps folder
# export ppsfolder=/home/evandro/xmm/obs/hd000000/2000jan01/pps
# cp $ppsfolder/*REGION* ./regions.reg 

export SAS_IMAGEVIEWER=ds9
export SAS_MEMORY_MODEL=high
export SAS_VERBOSITY=5
export XPA_METHOD=local

#Build calibration files index
cifbuild

#Point to the calibration index
export SAS_CCF=$PWD/ccf.cif

#Create observation summary
odfingest

#Point to the Summary file
export SAS_ODF=$PWD/`ls -1 | grep SUM.SAS`

#Reprocess data
epproc  # PN camera
emproc  # MOS cameras
#(one can use "(ep/em)chain" instead, see the SAS documentation)

#Check everything
sasversion
