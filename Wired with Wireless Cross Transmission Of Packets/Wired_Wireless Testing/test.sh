num_wired=2;
num_wireless=4;
flow_wired_to_wireless=2;

flow_wired=1;
packetsPerSec=200;
connections_with_base=1;
tclFile="wiredAndwireless.tcl";

clear;
echo "Running $tclFile ... ";

ns "$tclFile" "$num_wired" "$num_wireless" "$flow_wired_to_wireless" "$flow_wired" "$packetsPerSec" "$connections_with_base";


