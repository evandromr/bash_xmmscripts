#!/bin/bash

cp `ls -1 $xmm_rpcdata/*MOS2*ImagingEvts.ds` ./mos2evts_barycen.ds
cp $PWD/../src_evt.reg ./

# Make barycentric correction on the clean event file
barycen table=mos2evts_barycen.ds:EVENTS

# Get the coordinates from the .reg file
while read LINE
do
    srcregion=$LINE
done < src_evt.reg

export srcregion
export mos2table=mos2evts_barycen.ds

export fsrcname="mos2evts_src_0310keV.ds"
export fimgname="mos2evts_src_img_0310keV.ds"
export emin=300
export emax=10000
source mos2selev.sh

export fsrcname="mos2evts_src_032keV.ds"
export fimgname="mos2evts_src_img_032keV.ds"
export emin=300
export emax=2000
source mos2selev.sh

export fsrcname="mos2evts_src_245keV.ds"
export fimgname="mos2evts_src_img_245keV.ds"
export emin=2000
export emax=4500
source mos2selev.sh

export fsrcname="mos2evts_src_4510keV.ds"
export fimgname="mos2evts_src_img_4510keV.ds"
export emin=4500
export emax=10000
source mos2selev.sh
