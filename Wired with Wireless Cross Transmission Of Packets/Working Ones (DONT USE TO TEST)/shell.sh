
clear;
onlyGraph=0;
plotGraphs=1;
remove=1;


if [[ $remove -eq 1 ]]; then
	for (( i = 0; i < 3; i++ )); do
		rm -f "$i";
		rm -f "OutputGraph_$i.png";
	done
fi


if [[ $onlyGraph -eq 0 ]]; then
	traceFile="wired-and-wireless.tr";

	awkWireless="awkFile.awk";
	awkWired="wiredAwk.awk";
	tclFile="tclFile.tcl";

	echo "Running tcl file now for Wired-Wireless Cross Transmission";
	ns "$tclFile" ;

	echo ;
	echo "Running awk file now for wireless nodes .";
	awk -f "$awkWireless" "$traceFile";


	echo ;

	echo "Now Running awk file for WIRED nodes...";

	awk -f "$awkWired" "$traceFile"

	echo ;
	echo "Running nam file now .";



	#nam wired-and-wireless.nam & 

fi


if [[ $plotGraphs -eq 1 ]]; then
		#textFileReceived = "$i";
	for (( i = 0; i < 3; i++ )); do
		#i=0;
		graphFileName="plotGraphs_QueueVariation.sh";
		titleOfGraph="Queue size variation with time";
		xAxis="Time / s";
		yAxis="Queue size / bytes";
		outputPNGFile="OutputGraph_$i.png";

		gnuplot -c "$graphFileName" "$titleOfGraph" "$xAxis" "$yAxis" "$i" "$outputPNGFile";

	done

fi


