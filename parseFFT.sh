#!/bin/bash
# TODO accept some args
# TODO - max freq, input file, output file
awk '
	BEGIN {
		# TODO calculate 
		bin_width = -1
		f1_hz = 0.0
		start_time = 0.0
		row_time = 0.0
		actual_row_time = 0.0
		max_freq = 120
	}
	$1 ~ "^[0-9]*.?[0-9]*.$"  {
		if (bin_width == -1) {
			start_time = $1
		    bin_width = $2
			f1_hz = $3
		} else {
			if (($1 - start_time) == actual_row_time) {
				# TODO postprocess to calculate the correct interval 
				row_time = row_time + 0.025
			} else {
				row_time = $1 - start_time
				actual_row_time = row_time
			}
		}
		for (i = 4; i <= NF; i++) {
		    freq = f1_hz + (bin_width * (i-4))
			if (freq < max_freq) {
				print row_time, freq, $i 
			}
		}
		print ""
	}
' sample/digital_fft.txt > sample/fft_for_gnuplot.txt