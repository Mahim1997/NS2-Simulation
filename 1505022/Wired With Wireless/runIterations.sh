clear; 


awkWireless="awkFile.awk";
awkWired="wiredAwk.awk";
tclFile="wiredAndwireless.tcl";


runAwkWired(){
	awk -v folderOutput="$queue_folder_iter1" -v maxNode="$maxNode" -f "$awkWired" "$traceFile" ;
}

runAwkWireless(){
	awk -f "$awkWireless" "$traceFile";
}

	#ns "$tclFile" "$num_wired" "$num_wireless" "$flow_wired_to_wireless" \
	#"$flow_wired" "$packetsPerSec" "$connections_with_base"\
	#"$traceFile" "$namFile" "$topoFile" ;
