#!/bin/sh
#
# Script to reprocess observation data files
#

# Set a new environment variable point to this folder
export xmm_rpcdata=$PWD

#Point to Raw Observation Data directory
export SAS_ODF=$HOME/Work/XMM/XMM_ODF/$OBSID

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
