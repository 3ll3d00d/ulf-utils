#!/bin/bash 

gnuplot <<EOF
# set the output
set term png size 2560,1440 
set output "sample/eot_x.png"
#set multiplot layout 4, 1 title "Edge of Tomorrow - Opening" 
set multiplot layout 2, 1 title "Edge of Tomorrow - Opening" 
set tmargin 2
set lmargin at screen 0.05
set rmargin at screen 0.95

# Vibration
#set title "Vibration"
set datafile separator ","
set xlabel 'time (s)'
set autoscale
set xrange [3:18]
set xtics 3,1,18

set ylabel 'vibration x (g)'
plot 'sample/coolrda_vib_eot.csv' using 1:2 title 'X' with lines linestyle 1
#set ylabel 'vibration y (g)'
#plot 'sample/coolrda_vib_eot.csv' using 1:3 title 'Y' with lines linestyle 1
#set ylabel 'vibration z (g)'
#plot 'sample/coolrda_vib_eot.csv' using 1:4 title 'Z' with lines linestyle 1

# plot 2 - spectro
#set title "Digital Spectro"
set datafile separator " "

# plot features
set pm3d map
set contour surface
set pm3d interpolate 20,20
set cntrparam cubicspline

# x = time
# y = freq
# z = amplitude

# formatting of axes etc
#set logscale x 10

# TODO calculate the min and max time
set xlabel 'time (s)'
set xrange [1:17.5]
set xtics 0,1,30

# TODO calculate the min and max freq
# frequency
set yrange [0:90]
set mytics 10
set ylabel 'Frequency (Hz)'

#set key outside
#set key top right
set key off

# black background
#set object 1 rectangle from screen 0,0 to screen 1,1 fillcolor rgbcolor "black" behind 

# jet palette
f(x)=1.5-4*abs(x)
set palette model RGB
set palette functions f(gray-0.75),f(gray-0.5),f(gray-0.25)

#TODO calculate the min and max dBFS
# plot the absolute view
set cntrparam levels incremental -70,10,0
set cbrange [-70:0]
#set output "sample/spectro.png"
splot 'sample/fft_for_gnuplot.txt' using 1:2:3 title "                      " 

EOF
