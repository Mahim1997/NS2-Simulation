#!/bin/bash
#sat-wired_1.tcl
rm -f *.txt;

variedBandwidth=('1.5' '2.0' '2.5' '3.0' '3.5');	#Mb

variedPolarOrbit=('90' '80' '70' '60' '50')

for (( i = 1; i <= 5; i++ )); do
	tclFileName="sat-wired_""$i"".tcl";
	awkFile="awkFile.awk";
	echo "Running tcl File now ... ";
	echo "ns "$tclFileName";";
	ns "$tclFileName";
	traceFile="Trace.tr";
	awk -v variable="${variedPolarOrbit[$i]}" -f "$awkFile" "$traceFile" ;
done