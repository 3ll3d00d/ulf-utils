# ULF Utils

A very early hacked together set of scripts to support the analysis of vibration data collected from vibsensor during playback of known ULF scenes.

The basic approach is to combine data from different apps into a single graph so as to help see areas worthy of further investigation.

# Data Sources

* ULF scene

Pick ULF scene
Use desertdome's approach for extracting a wav containing the SW feed of a scene - http://www.avsforum.com/forum/113-subwoofers-bass-transducers/1333462-new-master-list-bass-movies-frequency-charts-post23468771.html#post23468771

Open speclab

Menu/Export FFT (spectrum) as text file
- Pick a filename
- Set datetime format as ss.s
- Column separator 32 (space)
- Frequency of 1st bin 0.0
- check the active box
(you probably need to restart speclab at this point, it seems to buffer the content and then flush on speclab exit)

Analyse the wav file using speclab and pick up the fft output file

* Vibsensor output

Playback the scene
Set vibsensor to record using coolrda's method
export the vibration data

# Analysis

This is currently a manual hack but basically

* convert the speclab FFT into a form gnuplot can easily read by running parseFFT.sh on it (have to hack script to take filenames & note the TODOs)
* run generate.sh to produce a png that contains 3 line charts (1 per vibration axis) and 1 spectrogram of the fft
* it also 

# Tools Required

* sox
* speclab
* bash/awk
* vibsensor
