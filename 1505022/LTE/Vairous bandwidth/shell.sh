#!/bin/bash
#AMR: 12.2, 10.2, 7.95, 7.40, 6.70

variables_arr=('12.2' '10.2' '7.95' '7.40' '6.70');

###CLEAR ALL text files
rm -f *.txt;


for (( i=0; i<5; i++ )); do
	val=${variables_arr[$i]};
	idx=$(($i+1));	
	tclFileName="LTEnew_""$idx"".tcl";
	
	ns $tclFileName;
	awk -v changedValue="$val" -f "wiredAwk.awk" "out.tr" ;	
	
done

################### PLOT GRAPHS ########################


