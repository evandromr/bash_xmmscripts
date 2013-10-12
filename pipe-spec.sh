#!/bin/bash
#
# A script to automate the generation of scientific products
#

# the XMM observation ID
export ppsfolder=$HOME/Work/XMM/OBS/hd161103/2012sep08/pps
echo "--- Pipeline to data reduction of the XMM-NEWTON space telescope ---"
echo "----------------- intended to point sources only -------------------"

echo "Reprocessing data"
cd rpcdata/
source rpcdata.sh > rpcdata.log
echo "End of data reduction"

echo "Starting the generation of scientific products"

#=========================================================
#--------------- Camera PN ---------------
cd ../pn

echo "Cleaning PN events..."
source clearpnevts.sh > clear.log
echo "DONE"
cp $ppsfolder/*REGION* ./regions.reg
echo "Select the regions src.reg, bkg.reg and src_evt.reg"
ds9 PN_image_clean.ds -regions load regions.reg -cmap Heat -log -smooth yes \
-zoom 4
# ------------ Spectrum PN ---------------
echo "Starting PN spectrum extraction..."
cd spec
source pnspec.sh > spec.log
echo "DONE"

#=========================================================
#------------- Camera MOS1 ---------------
cd ../../mos1
cp ../pn/src.reg ./
cp ../pn/bkg.reg ./
cp ../pn/src_evt.reg ./
cp ../pn/regions.reg ./
echo "Cleaning MOS1 event files..."
source clearmos1evts.sh > clear.log
echo "DONE"
echo "Select the regions src.reg, bkg.reg and src_evt.reg"
ds9 MOS1_image_clean.ds -regions load regions.reg -cmap Heat -log -smooth yes \
-zoom 4 -regions load src.reg -regions load bkg.reg -regions load src_evt.reg
# ---------- Spectrum MOS1 -----------------
cd spec
echo "Extracting MOS1 spectrum..."
source mos1spec.sh > spec.log
echo "DONE"

#=========================================================
# ---------- Camera MOS2 ------------------
cd ../../mos2
cp ../mos1/src.reg ./
cp ../mos1/src_evt.reg ./
cp ../mos1/bkg.reg ./
cp ../mos1/regions.reg ./
echo "Cleaning MOS2 events file"
source clearmos2evts.sh > clear.log
echo "DONE"
echo "Select the regions src.reg, bkg.reg and src_evt.reg"
ds9 MOS2_image_clean.ds -regions load regions.reg -cmap Heat -log -smooth yes \
-zoom 4 -regions load src.reg -regions load bkg.reg -regions load src_evt.reg
# ----------- Spectrum MOS2 ---------------
cd spec
echo "Extracting MOS2 spectrum..."
source mos2spec.sh > spec.log
echo "DONE"

---------------------------------------------
cd ../../
echo ""
echo "Spectra ready to analysis"
echo ""
echo "check the results and log files"
echo "------------END-------------"
