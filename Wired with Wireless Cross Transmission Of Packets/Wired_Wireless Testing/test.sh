packetsPerSec=200;

num_wired=2;
num_wireless=4;
flow_wired_to_wireless=6;
flow_wired=1;
connections_with_base=1;

chooseCrazyMode=1;


if [[ $chooseCrazyMode -eq 1 ]]; then
	num_wired=10;	
	num_wireless=40;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=500;

fi

tclFile="wiredAndwireless.tcl";

clear;
echo "Running $tclFile ... ";
iteration="7";

traceFile="Trace_""$iteration"".tr";
topoFile="Topo_""$iteration"".txt";
namFile="Nam_""$iteration"".nam";

 ns "$tclFile" "$num_wired" "$num_wireless" "$flow_wired_to_wireless" \
	"$flow_wired" "$packetsPerSec" "$connections_with_base"\
	"$traceFile" "$namFile" "$topoFile" ;


echo ;
echo "Now running nam file ";

namFile="Nam_5.nam";

#nam "$namFile" & 


