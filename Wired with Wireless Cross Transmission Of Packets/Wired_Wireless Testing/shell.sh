
clear;

allOne=0;

allOne=1;

######################Set modes####################
runTCL=1;
plotGraphs=0;
remove=0;
runWirelessAwk=0;
runWiredAwk=0;
runNam=0;

if [[ $allOne -eq 1 ]]; then
	runTCL=1;
	plotGraphs=1;
	remove=1;
	runWirelessAwk=1;
	runWiredAwk=1;
	runNam=1;
fi

#runTCL=0;

###########################Set Files####################3
num_wired_nodes=2;
maxNode="3";
outputFolder="Output/";
queue_folder_iter1="$outputFolder""Queue_Itr1/";
traceFile="wired-and-wireless.tr";

awkWireless="awkFile.awk";
awkWired="wiredAwk.awk";
tclFile="wiredAndwireless.tcl";

chooseCrazyMode=0;



packetsPerSec=200;
num_wired=2;
num_wireless=4;
flow_wired_to_wireless=6;
flow_wired=1;
connections_with_base=1;

chooseCrazyMode=1;
namFile="Nam.nam";
traceFile="Trace.tr";
topoFile="Topo.txt";

getFiles(){
	index=$1;
	namFile="Files/Nam_""$index"".nam";
	traceFile="Files/Trace_""$index"".tr";
	topoFile="Files/Topo_""$index"".txt";
}

getParams(){
index="$1";
getFiles "$index";
if [[ $index -eq 0 ]]; then
	packetsPerSec=200;
	num_wired=2;
	num_wireless=4;
	flow_wired_to_wireless=6;
	flow_wired=1;
	connections_with_base=1;
	packetsPerSec=200;
elif [[ $index -eq 1 ]]; then
	num_wired=10;
	num_wireless=20;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 2 ]]; then	
	num_wired=10;	
	num_wireless=40;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 3 ]]; then	
	num_wired=10;	
	num_wireless=60;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 4 ]]; then	
	num_wired=10;	
	num_wireless=80;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 5 ]]; then	
	num_wired=10;	
	num_wireless=100;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 5 ]]; then	
	num_wired=10;	
	num_wireless=100;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 6 ]]; then	
	num_wired=10;	
	num_wireless=60;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 7 ]]; then	
	num_wired=20;	
	num_wireless=60;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 8 ]]; then	
	num_wired=30;	
	num_wireless=60;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 9 ]]; then	
	num_wired=40;	
	num_wireless=60;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 10 ]]; then	
	num_wired=50;	
	num_wireless=60;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 11 ]]; then	
	num_wired=20;	
	num_wireless=40;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=100;
elif [[ $index -eq 12 ]]; then	
	num_wired=20;	
	num_wireless=40;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=200;
elif [[ $index -eq 13 ]]; then	
	num_wired=20;	
	num_wireless=40;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=300;
elif [[ $index -eq 14 ]]; then	
	num_wired=20;	
	num_wireless=40;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=400;
elif [[ $index -eq 15 ]]; then	
	num_wired=20;	
	num_wireless=40;
	flow_wired_to_wireless=40;
	flow_wired=20;
	connections_with_base=5;
	packetsPerSec=500;

fi
}



remove(){
if [[ $remove -eq 1 ]]; then
	for (( i = 0; i < $num_wired; i++ )); do
		rm -f "$i";
		rm -f "$queue_folder_iter1""OutputGraph_$i.png";
	done
	#rm -rf "$queue_folder_iter1";
	#mkdir "$queue_folder_iter1";
	rm -rf "$outputFolder";
	rm -rf "$queue_folder_iter1";

	mkdir "$outputFolder";
	mkdir "$queue_folder_iter1";
fi
}
 
runTCL(){
iter="$1";
if [[ $runTCL -eq 1 ]]; then

echo "Running tcl file now for Wired-Wireless Cross Transmission iteration $iter " ;
	#ns "$tclFile" ;
#traceFile="Trace.tr";
#topoFile="Topo.txt";
#namFile="Nam.txt";

echo "	ns "$tclFile" "$num_wired" "$num_wireless" "$flow_wired_to_wireless" \
"$flow_wired" "$packetsPerSec" "$connections_with_base"\
"$traceFile" "$namFile" "$topoFile" ;";

	ns "$tclFile" "$num_wired" "$num_wireless" "$flow_wired_to_wireless" \
	"$flow_wired" "$packetsPerSec" "$connections_with_base"\
	"$traceFile" "$namFile" "$topoFile" ;

fi
}

runWirelessAwk(){
if [[ $runWirelessAwk -eq 1 ]]; then
	echo ;
	echo "Running awk file now for wireless nodes .";
	awk -f "$awkWireless" "$traceFile";
fi

}
runWiredAwk(){
if [[ $runWiredAwk -eq 1 ]]; then
	echo ;

	echo "Now Running awk file for WIRED nodes...";
#file_throughput="$file1"
	awk -v folderOutput="$queue_folder_iter1" -v maxNode="$maxNode" -f "$awkWired" "$traceFile" ;

	echo ;
fi

}
plotGraphs(){
	echo "Insid plot graph function .. ";
if [[ $plotGraphs -eq 1 ]]; then
	

	for (( i = 0; i < $num_wired; i++ )); do
		#i=0;
		graphFileName="plotGraphs_QueueVariation.sh";
		titleOfGraph="Queue size variation with time";
		xAxis="Time / s";
		yAxis="Queue size / bytes";
		outputPNGFile="$queue_folder_iter1""OutputGraph_$i.png";

		textFileReceived="$queue_folder_iter1""Node_$i";
		#echo "textFileReceived = $textFileReceived";

		echo "gnuplot -c "$graphFileName" "$titleOfGraph" "$xAxis" "$yAxis" "$textFileReceived" "$outputPNGFile";";
		echo ;
		gnuplot -c "$graphFileName" "$titleOfGraph" "$xAxis" "$yAxis" "$textFileReceived" "$outputPNGFile";

	done

fi

}

removeAndMakeDir(){
	rm -rf 'Files/';
	mkdir 'Files/';
}

main(){
	runTCL=1;
	plotGraphs=0;
	remove=0;
	runWirelessAwk=0;
	runWiredAwk=0;
	runNam=0;

	if [[ $allOne -eq 1 ]]; then
		runTCL=1;
		plotGraphs=1;
		remove=1;
		runWirelessAwk=1;
		runWiredAwk=1;
		runNam=1;
	fi

	echo "Plotting Graphs";

	removeAndMakeDir ;

#	getParams "1";
#	runTCL "1";
	for (( i = 1; i <= 15; i++ )); do
		getParams "$i";
		runTCL "$i" ;
	done

	#plotGraphs
}




########################## RUN 

main 


