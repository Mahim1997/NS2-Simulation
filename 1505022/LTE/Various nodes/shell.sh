#!/bin/bash
#AMR: 12.2, 10.2, 7.95, 7.40, 6.70
#Avg page size
#Nodes

#variables_arr=('12.2' '10.2' '7.95' '7.40' '6.70');
initialPageSize=5120;
variables_arr_pageMult=('1' '2' '3' '4' '5');
variables_node=('10' '20' '30' '40' '50');

###CLEAR ALL text files
rm -f *.txt;


for (( i=0; i<5; i++ )); do
#	val=${variables_arr_pageMult[$i]};
#	val=$(($val*$initialPageSize));
	val=${variables_node[$i]};
	idx=$(($i+1));	
	
	tclFileName="LTEnew_""$idx"".tcl";

	ns $tclFileName;
	awk -v changedValue="$val" -f "wiredAwk.awk" "out.tr" ;	
	
#	echo "ns $tclFileName;"
#	echo "awk -v changedValue="$val" -f "wiredAwk.awk" "out.tr" ;"	
	
	
done



