
clear;

allOne=0;
allOne=1;

######################Set modes####################
runTCL=0;
plotGraphs=1;
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

###########################Set Files####################3
num_wired_nodes=2;
maxNode="3";
outputFolder="Output/";
queue_folder_iter1="$outputFolder""Queue_Itr1/";
traceFile="wired-and-wireless.tr";

awkWireless="awkFile.awk";
awkWired="wiredAwk.awk";
tclFile="wiredAndwireless.tcl";


if [[ $remove -eq 1 ]]; then
	for (( i = 0; i < 3; i++ )); do
		rm -f "$i";
		rm -f "$queue_folder_iter1OutputGraph_$i.png";
	done
	#rm -rf "$queue_folder_iter1";
	#mkdir "$queue_folder_iter1";
	rm -rf "$outputFolder";
	rm -rf "$queue_folder_iter1";

	mkdir "$outputFolder";
	mkdir "$queue_folder_iter1";
fi


if [[ $runTCL -eq 1 ]]; then


	echo "Running tcl file now for Wired-Wireless Cross Transmission";
	ns "$tclFile" ;

fi

if [[ $runWirelessAwk -eq 1 ]]; then
	echo ;
	echo "Running awk file now for wireless nodes .";
	awk -f "$awkWireless" "$traceFile";
fi

if [[ $runWiredAwk -eq 1 ]]; then
	echo ;

	echo "Now Running awk file for WIRED nodes...";
#file_throughput="$file1"
	awk -v folderOutput="$queue_folder_iter1" -v maxNode="$maxNode" -f "$awkWired" "$traceFile" ;

	echo ;
fi

if [[ $plotGraphs -eq 1 ]]; then
		#textFileReceived = "$i";
	for (( i = 0; i < $num_wired_nodes; i++ )); do
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


if [[ $runNam -eq 1 ]]; then
	echo "Running nam file now .";
	nam wired-and-wireless.nam & 
fi





