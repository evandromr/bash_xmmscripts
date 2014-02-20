#!/bin/bash
#
# A script to automate the generation of scientific products
#

# the XMM observation details (part of folder path)
export obsdetail=hdxxxxxx/yyyymmmdd
export ppsfolder=$HOME/xmm/obs/$obsdetail/pps
export odffolder=$HOME/xmm/obs/$obsdetail/odf

#==========================================================================
echo "--- Pipeline to data reduction of the XMM-NEWTON space telescope ---"
echo "----------------- intended to point sources only -------------------"
#===========================================================================
echo "Reprocessing data"
cd rpcdata/

source rpcdata.sh > rpcdata.log

echo "End of data reprocessesment"
echo " "

export PNevents=`ls -1 $xmm_rpcdata/*PN*ImagingEvts.ds*`
export MOS1events=`ls -1 $xmm_rpcdata/*MOS1*ImagingEvts.ds*`
export MOS2events=`ls -1 $xmm_rpcdata/*MOS2*ImagingEvts.ds*`

echo "PN times:"
ftkeypar $PNevents[EVENTS] TSTART chatter=3 
ftkeypar $PNevents[EVENTS] TSTOP chatter=3 
echo " "

echo "MOS1 times:"
ftkeypar $MOS1events[EVENTS] TSTART chatter=3 
ftkeypar $MOS1events[EVENTS] TSTOP chatter=3 
echo ""

echo "MOS2 times:"
ftkeypar $MOS2events[EVENTS] TSTART chatter=3 
ftkeypar $MOS2events[EVENTS] TSTOP chatter=3 
echo " "

echo "Enter common initial time for lightcurve analysis:"
read tstart
echo "Enter common final time for lightcurve analysis:"
read tstop
echo " "

cd ..
echo "Starting the generation of scientific products"
#=========================================================
#--------------- Camera PN --------------------------------------------------
echo "Cleaning PN events..."
cd pn

source clearpnevts.sh > pnclear.log

echo "DONE"

cp $ppsfolder/*REGION* ./regions.reg

echo ""
echo "Select the regions src.reg, bkg.reg and src_evt.reg"
echo ""

ds9 PN_image_clean.ds -regions load regions.reg -cmap Heat -log -smooth yes \
-zoom 4

# ------------ Spectrum PN -------------------------------------------------
echo "Starting PN spectrum extraction..."
cd spec

source pnspec.sh > pnspec.log

cd ..
echo "DONE"

# ------------ Events PN ---------------------------------------------------
echo "Starting PN event files extraction..."
cd events

source pneventscript.sh > pnevents.log
cd ..
echo "DONE"

# ------------ Light Curves PN --------------------------------------------
echo "Starting PN light curve extraction (full time)"
cd lightcurves

source pnlcscript.sh > pnlc.log

cd ..
echo "DONE"

# ----------- Timed Light Curves PN ---------------------------------------
echo "Starting PN light curve extraction (timed)"
cd timed_lightcurves

source pnlcscript_timed.sh > pnlct.log

cd ..
echo "DONE"

#============================================================================
#------------- Camera MOS1 --------------------------------------------------
cd ../mos1
cp ../pn/src.reg ./
cp ../pn/bkg.reg ./
cp ../pn/src_evt.reg ./
cp ../pn/regions.reg ./
echo "Cleaning MOS1 event files..."

source clearmos1evts.sh > mos1clear.log

echo "DONE"

echo "Select the regions src.reg, bkg.reg and src_evt.reg"
ds9 MOS1_image_clean.ds -regions load regions.reg -cmap Heat -log -smooth yes \
-zoom 4 -regions load src.reg -regions load bkg.reg -regions load src_evt.reg

# ---------- Spectrum MOS1 ------------------------------------------------
cd spec
echo "Extracting MOS1 spectrum..."

source mos1spec.sh > mos1spec.log

cd ..
echo "DONE"

# ------------ Events MOS1 -------------------------------------------------
echo "Starting MOS1 event files extraction..."
cd events

source mos1eventscript.sh > mos1events.log

cd ..
echo "DONE"

# ------------ Light Curves MOS1 -------------------------------------------
echo "Starting MOS1 light curve extraction (full time)"
cd lightcurves

source mos1lcscript.sh > mos1lc.log

cd ..
echo "DONE"

# ----------- Timed Light Curves MOS1 ---------------------------------------
echo "Starting MOS1 light curve extraction (timed)"
cd timed_lightcurves

source mos1lcscript_timed.sh > mos1lct.log

cd ..
echo "DONE"

#===========================================================================
# ---------- Camera MOS2 ---------------------------------------------------
cd ../mos2
cp ../mos1/src.reg ./
cp ../mos1/src_evt.reg ./
cp ../mos1/bkg.reg ./
cp ../mos1/regions.reg ./
echo "Cleaning MOS2 events file"

source clearmos2evts.sh > mos2clear.log

echo "DONE"

echo "Select the regions src.reg, bkg.reg and src_evt.reg"
ds9 MOS2_image_clean.ds -regions load regions.reg -cmap Heat -log -smooth yes \
-zoom 4 -regions load src.reg -regions load bkg.reg -regions load src_evt.reg

# ----------- Spectrum MOS2 -------------------------------------------------
cd spec
echo "Extracting MOS2 spectrum..."

source mos2spec.sh > mos2spec.log

cd ..
echo "DONE"

# ------------ Events MOS2 --------------------------------------------------
echo "Starting MOS2 event files extraction..."
cd events

source mos2eventscript.sh > mos2events.log

cd ..
echo "DONE"

# ------------ Light Curves MOS2 --------------------------------------------
echo "Starting MOS2 light curve extraction (full time)"
cd lightcurves

source mos2lcscript.sh > mos2lc.log

cd ..
echo "DONE"

# ----------- Timed Light Curves MOS2 ---------------------------------------
echo "Starting MOS2 light curve extraction (timed)"
cd timed_lightcurves

source mos2lcscript_timed.sh > mos2lct.log

cd ..
echo "DONE"

#---------------------------------------------------------------------------
cd ../
echo ""
echo "Scientific products ready to analysis"
echo ""
echo "check the results and log files"
echo "----------------------------END---------------------------------------"
