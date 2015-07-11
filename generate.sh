#!/bin/bash 
function usage {
    echo "generate.sh -d -x 1920 -y 1080 -p foo -t title -a 1 -b 10 -c 12"
    echo "    -d force delete of existing generated files"
    echo "    -x width of image in pixels, default 2560"
    echo "    -y height of image in pixels, default 1440"
	echo "    -t title for the image"
    echo "    -p file name prefix"
	echo "    -a start time for vibration data"
	echo "    -b start time for FFT data"
	echo "    -c duration"
}

function delete_or_blow {
    if [ "${FORCE_DELETE}" -eq 1 ]
    then
	    [[ -f "${1}" ]] && rm "${1}"
    else
        [[ -f "${1}" ]] && echo "${1} exists, exiting! use -d to continue or move the file" && exit 65
    fi    
}

function fail {
    echo $1
	exit $2
}

FORCE_DELETE=0
WIDTH=2560
HEIGHT=1440

while getopts "dx:y:p:a:b:c:" OPTION
do
     case $OPTION in
	 d)
	     SHIFT_COUNT=$((SHIFT_COUNT+1))
	     FORCE_DELETE=1
	     ;;
	 x)
	     SHIFT_COUNT=$((SHIFT_COUNT+2))
	     WIDTH="${OPTARG}"
	     ;;
	 y)
	     SHIFT_COUNT=$((SHIFT_COUNT+2))
	     HEIGHT="${OPTARG}"
	     ;;
	 p)
	     SHIFT_COUNT=$((SHIFT_COUNT+2))
	     PREFIX="${OPTARG}"
	     ;;
     t) 
	     SHIFT_COUNT=$((SHIFT_COUNT+2))
	     CHART_TITLE="${OPTARG}"
	     ;;
     a) 
	     SHIFT_COUNT=$((SHIFT_COUNT+2))
	     VIB_START="${OPTARG}"
	     ;;
     b) 
	     SHIFT_COUNT=$((SHIFT_COUNT+2))
	     FFT_START="${OPTARG}"
	     ;;
     c) 
	     SHIFT_COUNT=$((SHIFT_COUNT+2))
	     DURATION="${OPTARG}"
	     ;;
	 *)
		 usage
		 exit 1
		 ;;
     esac
done
shift ${SHIFT_COUNT}

if [ $# -eq 1 ]
then
    TARGET_DIR="${1}"    
fi
if [ -z "${PREFIX}" ]
then
    echo "Measurements must have a prefix"
    exit 67
fi

[ -e ${TARGET_DIR}/${PREFIX}_vib.csv ] || fail "Vibration file (${TARGET_DIR}/${PREFIX}_vib.csv) does not exist" 68 
[ -e ${TARGET_DIR}/${PREFIX}_fft.txt ] || fail "FFT file (${TARGET_DIR}/${PREFIX}_fft.txt) does not exist" 68 

echo "Generating plots using ${TARGET_DIR}/${PREFIX}_fft.txt and ${TARGET_DIR}/${PREFIX}_vib.csv"

delete_or_blow "${TARGET_DIR}/${PREFIX}.png"

# locate the min/max vibration values
VIB_SCALE=($(awk -F"," '
BEGIN { min_vib = 1000; max_vib = 0; } 
/^[0-9]/ { 
    if ($2 < min_vib) { min_vib = $2 }
    if ($3 < min_vib) { min_vib = $3 }
    if ($4 < min_vib) { min_vib = $4 }
    if ($2 > max_vib) { max_vib = $2 }
    if ($3 > max_vib) { max_vib = $3 }
    if ($4 > max_vib) { max_vib = $4 }
}
END { print min_vib " " max_vib }
' ${TARGET_DIR}/${PREFIX}_vib.csv ))
echo "Plotting vibrations to scale ${VIB_SCALE[0]} : ${VIB_SCALE[1]}"

VIB_END=$(echo "${VIB_START}+${DURATION}" | bc)
FFT_END=$(echo "${FFT_START}+${DURATION}" | bc)
echo "Plotting vibrations from ${VIB_START}s to ${VIB_END}s"
echo "Plotting FFT from ${FFT_START}s to ${FFT_END}s"

gnuplot <<EOF
# set the output
set term png size ${WIDTH},${HEIGHT} 
set output "${TARGET_DIR}/${PREFIX}.png"
set multiplot layout 5,1 title "${TITLE}"
set tmargin 2
set lmargin at screen 0.05
set rmargin at screen 0.95

# Vibration
set xrange [${VIB_START}:${VIB_END}]
set yrange [${VIB_SCALE[0]}:${VIB_SCALE[1]}]
set xtics ${VIB_START},1,${VIB_END}
set datafile separator ","

set ylabel 'vibration x (g)'
plot '${TARGET_DIR}/${PREFIX}_vib.csv' using 1:2 title 'X' with lines linestyle 1
set ylabel 'vibration y (g)'
plot '${TARGET_DIR}/${PREFIX}_vib.csv' using 1:3 title 'Y' with lines linestyle 2
set ylabel 'vibration z (g)'
plot '${TARGET_DIR}/${PREFIX}_vib.csv' using 1:4 title 'Z' with lines linestyle 3

# plot 2 - spectro
set datafile separator " "

# plot features
set pm3d map
#set contour surface
set pm3d interpolate 20,20
set cntrparam cubicspline

# x = time
# y = freq
# z = amplitude

set xlabel 'time (s)'
set xrange [${FFT_START}:${FFT_END}]
set xtics ${FFT_START},1,${FFT_END}

# frequency
set yrange [0:100]
set mytics 10
set ylabel 'Frequency (Hz)'

set key off

# jet palette
f(x)=1.5-4*abs(x)
set palette model RGB
set palette functions f(gray-0.75),f(gray-0.5),f(gray-0.25)

# plot the absolute view
set cntrparam levels incremental -70,5,0
set cbrange [-70:0]
set bmargin at screen 0.05
splot '${TARGET_DIR}/${PREFIX}_fft.txt' using 1:2:3 title "                      " 

EOF
