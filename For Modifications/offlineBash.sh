#!/bin/bash
####################################For modifications ....
##For 802.11 static
ifModified_congestion=0;	#If this is 1 , then use modification
whichCase_congestion=9;	#For modified congestion control mechanism
##For 802.15.4 mobile
ifModified_congestion_mobile=0;	#For now do not use mobile modification ...
grid_or_rand_mobile=0;
###############For png files
description_arr_static=('802.11 Wireless Static');
description_arr_mobile=('802.15.4 Wireless Mobile');
description_arr_static_index=1;
description_arr_mobile_index=1;
staticOrMobile=0;	#0 = static, 1 = mobile
parameters_arr=('Number of nodes' 'Number of flows' 'Number of packets per second' 'Tx_Range' 'Speed of nodes');
textFile_arr=('NodeVarying' 'FlowVarying' 'PacketsPerSecVarying' 'Tx_RangeVarying' 'SpeedNodesVarying');
textFile_arr_mobile=('NodeVarying' 'FlowVarying' 'PacketsPerSecVarying' 'SpeedNodesVarying');
parameters_arr_mobile=('Number of nodes' 'Number of flows' 'Number of packets per second' 'Speed of nodes');
#metricsMeasured_arr=('_NetworkThroughput.csv' '_EndToEndDelay.csv' '_PacketDeliveryRatio.csv' '_PacketDropRatio.csv' '_EnergyConsumption.csv');
metrics_arr=('Network Throughput (bits/sec)' 'End to End Delay (sec)' 'Packet Delivery Ratio (%)' 'Packet Drop Ratio (%)' 'Total Energy Consumption (Joules)');
pngFiles_arr=('_NetworkThroughput.png' '_EndToEndDelay.png' '_PacketDeliveryRatio.png' '_PacketDropRatio.png' '_EnergyConsumption.png');
textFileToRun="NULL";
outputPNGFile="NULL_OUTPUT";
titleOfGraph="NULL_TITLE";
xAxis="x-axis";
yAxis="y-axis";
folderOfTextFiles_Static="Wireless_Static_TCP/For_Graphs/";
folderOfTextFiles_Mobile="Mobile_Wireless_TCP/For_Graphs/";
##############Global variables
folderName="Wireless_Static_TCP";
folderName_Mobile="Mobile_Wireless_TCP";
tclFileName="tcl_wireless_static.tcl";
awkFileName="awk_wireless_static.awk";
tclFileName_Mobile="tcl_wireless_mobile.tcl";
folder_Files='Files'
folder_Reports='Reports'

graphFileName_Static='plotGraphs_Static.sh';
graphFileName_Mobile='plotGraphs_Mobile.sh';

index_counter=1;	#For index counting for trace and nam variables...
SCALE_FLOAT=7;
startTime=100;
time_gap=50;
x_dim=1000;
y_dim=900;
grid_1_random_0="1";
sizeOFNODE=10;	#node er initially size dekhar jonne 


constant_idx=0;	#Use constant index  when varying other parameters

index_counter=1;	#Initialize counter ....
maxVariations=5;	#Maximum number of variations = 5
############Arrays

###################DEBUG PARAMETERS
onlyAwk=1;


#########################CSV Folder names eg.Wireless_Static_TCP/ [ONLY TO NAVIGATE...]
folderForGraphs="For_Graphs";
folderCSV_staticWireless="$folderName/$folderForGraphs/";
folderCSV_mobileWireless="$folderName_Mobile/$folderForGraphs/";

csv_folder_returned_from_function="NavigatedFolder";
#######################CSV FILES names (to plot graphs)
csvFile_arr=('NodeVarying' 'FlowVarying' 'PacketsPerSecVarying' 'Tx_RangeVarying' 'SpeedNodesVarying');
#metricsMeasured_arr=('_NetworkThroughput.csv' '_EndToEndDelay.csv' '_PacketDeliveryRatio.csv' '_PacketDropRatio.csv' '_EnergyConsumption.csv');
metricsMeasured_arr=('_NetworkThroughput.txt' '_EndToEndDelay.txt' '_PacketDeliveryRatio.txt' '_PacketDropRatio.txt' '_EnergyConsumption.txt');
##########################CSV FILE (return from function) after adding correct folder names and variations
csvFile_return_from_function="NULL.csv";
csvFile_variations=('node' 'flow' 'packetesPerSec' 'Tx_Range' 'nodeSpeed');
nameFile_CSV_toBeUsed=('');
#################################Function to get correct csv files

getCSVFile_factory(){
	whichFile="$1";
	if [[ "$whichFile" == ${csvFile_variations[0]} ]]; then
		csvFile_return_from_function="${csvFile_arr[0]}";
	elif [[ "$whichFile" == ${csvFile_variations[1]} ]]; then
		csvFile_return_from_function="${csvFile_arr[1]}";
	elif [[ "$whichFile" == ${csvFile_variations[2]} ]]; then
		csvFile_return_from_function="${csvFile_arr[2]}";
	elif [[ "$whichFile" == ${csvFile_variations[3]} ]]; then
		csvFile_return_from_function="${csvFile_arr[3]}";
	elif [[ "$whichFile" == ${csvFile_variations[4]} ]]; then
		csvFile_return_from_function="${csvFile_arr[4]}";
	fi
}
getCSVFile_UsingCorrectFile(){
	mode="$1";
	whichFile="$2";
	
	if [[ "$whichFile" == ${csvFile_variations[0]} ]]; then
		csvFile_return_from_function="${csvFile_arr[0]}";
	elif [[ "$whichFile" == ${csvFile_variations[1]} ]]; then
		csvFile_return_from_function="${csvFile_arr[1]}";
	elif [[ "$whichFile" == ${csvFile_variations[2]} ]]; then
		csvFile_return_from_function="${csvFile_arr[2]}";
	elif [[ "$whichFile" == ${csvFile_variations[3]} ]]; then
		csvFile_return_from_function="${csvFile_arr[3]}";
	elif [[ "$whichFile" == ${csvFile_variations[4]} ]]; then
		csvFile_return_from_function="${csvFile_arr[4]}";
	fi

	if [[ $mode -eq 0 ]]; then
		folderUsed="$folderCSV_staticWireless";
	elif [[ $mode -eq 1 ]]; then
		folderUsed="$folderCSV_mobileWireless";
	fi
	csvFile_return_from_function="$folderUsed/$csvFile_return_from_function";
}

getCSVFolderUsingMode(){
	mode="$1";
	if [[ $mode -eq 0 ]]; then
		csv_folder_returned_from_function="$folderCSV_staticWireless";
	elif [[ $mode -eq 1 ]]; then
		csv_folder_returned_from_function="$folderCSV_mobileWireless";
	fi	
}
navigateToCSVFileUsingMode(){
	mode="$1";
	if [[ $mode -eq 0 ]]; then
		cd "$folderCSV_staticWireless";
	elif [[ $mode -eq 1 ]]; then
		cd "$folderCSV_mobileWireless";
	fi
}

###############Default values/strings
nam_pre_string="Nam_";
nam_post_string=".nm";
trace_pre_string="Trace_";
trace_post_string=".tr";
topo_pre_string="Topo_";
topo_post_string=".txt";


#############Parameters for functions
cbr_interval_from_function=0.1;	#Default 0.1
packets_per_sec_for_function=100;	#Default 100
trace_file_from_function="Trace.tr";
nam_file_from_function="NamFile.nam";
topo_file_from_function="Topo.txt";

#############Functions
removeDirectories(){
	rm -rf "$folderName/";
	rm -rf "$folderName_Mobile/";
}

makeDirectories(){

	mkdir "$folderName/";
	cd "$folderName/";

	#mkdir 'Files/'
	mkdir "$folder_Files/";
	#mkdir 'Reports/'
	mkdir "$folder_Reports/";

	#mkdir 'For_Graphs/'
	mkdir "$folderForGraphs/";

	cd ..	


	mkdir "$folderName_Mobile/";
	cd "$folderName_Mobile/"

	#mkdir 'Files/'
	mkdir "$folder_Files/";
	#mkdir 'Reports/'
	mkdir "$folder_Reports/";

	#mkdir 'For_Graphs/'
	mkdir "$folderForGraphs/";

	cd ..	


}
makeCorrectFolder(){
	if [[ $staticOrMobile -eq 1 ]]; then
		folderName=$folderName_Mobile;
	fi
}
get_cbr_interval(){
	packetsPerSec=$1;
	#echo "INSIDE get_cbr_interval ... parameter is $packetsPerSec"
	#bc <<< 'scale=2; 100/3';
	#cbr_interval_from_function=`bc <<< 'scale=2; 100/3'`;
 	cbr_interval_from_function=`bc <<< "scale=$SCALE_FLOAT; 1/$packetsPerSec"`;
	#echo "Exiting get_cbr_interval ... cbr_interval_from_function = $cbr_interval_from_function"
}
get_nam_file(){
	iteration=$1;
	nam_file_from_function=$folderName/'Files'/$nam_pre_string$iteration$nam_post_string
}
get_trace_file(){
	iteration=$1;
	trace_file_from_function=$folderName/'Files'/$trace_pre_string$iteration$trace_post_string
}
get_topo_file(){
	iteration=$1;
	topo_file_from_function=$folderName/'Files'/$topo_pre_string$iteration$topo_post_string
}

runOnce(){
	num_row=$1;
	num_col=$2;
	parallel_flow=$3;
	cross_flow=$4;
	#packets_per_sec=$5;
	#get_cbr_interval $packets_per_sec;
	cbr_interval=$5;
	coefficientOfTxRange=$6;

	indexGiven=$7;

	get_nam_file $indexGiven;
	get_trace_file $indexGiven;
	get_topo_file $indexGiven;
	namFileName=$nam_file_from_function;
	traceFileName=$trace_file_from_function;
	topoFileName=$topo_file_from_function;

	packets_per_sec=$8;
	#echo "Immedaitely upore 10th param  is $10"
	#sizeOfNode=$((num_col * num_row));
	#startTime=$14;
	#time_gap=$15;

	echo; echo;
	echo "num_row = $num_row , num_col = $num_col, parallel_flow = $parallel_flow, cross_flow = $cross_flow"
	echo "cbr_interval = $cbr_interval [packets_per_sec = $packets_per_sec] , coefficientOfTxRange = $coefficientOfTxRange"
	echo "indexGiven = $indexGiven"
	echo "namFileName = $namFileName"; echo "traceFileName = $traceFileName";echo "topoFileName = $topoFileName"
	echo "x_dim = $x_dim, y_dim = $y_dim, grid_1_random_0 = $grid_1_random_0"; echo "tclFileName = $tclFileName"
	echo "startTime = $startTime, time_gap = $time_gap"
	echo; echo;

	numNodes=$(($num_row * num_col));
	#echo -e "Nodes = $numNodes, Flow = $parallel_flow, Packets per second = $packets_per_sec, Coeverage area Multiplier = $coefficientOfTxRange\n\n" >> "Check.txt";
	descriptionNow="Nodes = $numNodes, Flow = $parallel_flow, Packets per second = $packets_per_sec, Coeverage area Multiplier = $coefficientOfTxRange\n\n";
	description_arr_static[description_arr_static_index]=$descriptionNow;
	description_arr_static_index=$(($description_arr_static_index + 1));



	ns "$tclFileName" $num_row $num_col \
	$parallel_flow $cross_flow \
	$cbr_interval $coefficientOfTxRange \
	$namFileName $traceFileName \
	$topoFileName $x_dim \
	$y_dim $grid_1_random_0 \
	$startTime $time_gap\
	$sizeOFNODE\
	$ifModified_congestion\
	$whichCase_congestion;		#if modified is 1, then use Case 9  that we have modified in tcp.cc
	#echo; echo;
}
runMobileOnce(){
	nodeNum=$1;
	flowNum=$2;
	packetsPerSec=$3;
	nodeSpeed=$4;
	indexGiven=$5;

	get_nam_file $indexGiven;
	get_trace_file $indexGiven;
	get_topo_file $indexGiven;
	namFileName=$nam_file_from_function;
	traceFileName=$trace_file_from_function;
	topoFileName=$topo_file_from_function;

	#echo "Inside runMobileOnce () nodeNum = $nodeNum, flowNum = $flowNum, packetsPerSec = $packetsPerSec, nodeSpeed = $nodeSpeed , indexGiven = $indexGiven";
	#echo "Trace file name: $traceFileName , Nam File Name: $namFileName, Topo: $topoFileName";
	descriptionNow="Number of Nodes = $nodeNum, Flow = $flowNum, Packets per sec = $packetsPerSec, Node speed = $nodeSpeed\n\n" ;
	description_arr_mobile[description_arr_mobile_index]="$descriptionNow";
	description_arr_mobile_index=$(($description_arr_mobile_index + 1));

	row=$6;
	col=$(($nodeNum/$row));

	#col=10;
	#row=$((nodeNum/col));

	echo -e "$indexGiven. Number of Nodes = $nodeNum, Flow = $flowNum, Packets per sec = $packetsPerSec, Node speed = $nodeSpeed, row = $row, col = $col\n\n" ; #>> "Check.txt";

	grid_or_rand_mobile=0;
	
	if [[ $grid_or_rand_mobile -eq 0 ]]; then
		x_dim=200;
		y_dim=200;		
	else
		x_dim=1000;
		y_dim=1000;
	fi
	#x_dim=1000;
	#y_dim=1000;


	num_col=$col;
	num_row=$row;

	x_start_denom=$(( num_col * 2 ));
	y_start_denom=$(( num_row * 2 ));

	x_start=$(( x_dim/x_start_denom ));	#set x_start [expr int($grid_x_dim/($num_col*2))];
	y_start=$(( y_dim/y_start_denom ));	#set y_start [expr int($grid_y_dim/($num_row*2))];

	add_to_x=$(( x_dim/num_col ));				# = ($grid_x_dim/$num_col)
	add_to_y=$(( y_dim/num_row ));				# = ($grid_y_dim/$num_row)

	sizeNode=$((x_dim/40));

	#echo "ns $tclFileName_Mobile $nodeNum $flowNum $packetsPerSec $nodeSpeed $namFileName $traceFileName $topoFileName \
	#$ifModified_congestion_mobile $grid_or_rand_mobile \
	#$row $col $x_dim $y_dim $x_start $y_start $add_to_x $add_to_y;";

	ns $tclFileName_Mobile $nodeNum $flowNum $packetsPerSec $nodeSpeed $namFileName $traceFileName $topoFileName \
	$ifModified_congestion_mobile $grid_or_rand_mobile \
	$row $col $x_dim $y_dim $x_start $y_start $add_to_x $add_to_y\
	$sizeNode;


#	ns $tclFileName_Mobile $nodeNum $flowNum $packetsPerSec $nodeSpeed $namFileName $traceFileName $topoFileName $ifModified_congestion_mobile $grid_or_rand_mobile $row $col;
	#ns $tclFileName_Mobile $nodeNum $flowNum $packetsPerSec $nodeSpeed $namFileName $traceFileName $topoFileName $ifModified_congestion_mobile $grid_or_rand_mobile;

	echo -e "\n--->>>  INSIDE SHELL SCRIPT, Executed ns .... for $indexGiven\n";
	#ns $tclFileName_Mobile $nodeNum $flowNum $packetsPerSec $nodeSpeed $namFileName $traceFileName $topoFileName
	#echo "ns $tclFileName_Mobile $nodeNum $flowNum $packetsPerSec $nodeSpeed $namFileName $traceFileName $topoFileName";
	#echo; echo;
}

##############################################Changing arrays#########################################
cols_arr=('5' '8' '10' '10' '10');
rows_arr=('4' '5' '6' '8' '10');

nodes_arr=('20' '40' '60' '80' '100');
flows_arr=('10' '20' '30' '40' '50');
numberOfPacketsPerSec_arr=('100' '200' '300' '400' '500');
coverageMultiplier_arr=('1' '2' '3' '4' '5');	#ONLY FOR STATIC
speedOfNodes_arr=('5' '10' '15' '20' '25');	#ONLY FOR MOBILE


######################################## Runner functions #######################################
varyNodes(){
	#=================Varying number of nodes now =========================
	echo; echo "Now varying nodes";

	for (( i = 0; i < $maxVariations; i++ )); do
		#nodeNum=${nodes_arr[$i]};
		rowNum=${rows_arr[$i]};
		colNum=${cols_arr[$i]};
		flowNum=${flows_arr[1]};
		pkts_per_sec=${numberOfPacketsPerSec_arr[4]};
		get_cbr_interval "$pkts_per_sec" ;
		cbr_interval=$cbr_interval_from_function;
		coverage_coefficient=${coverageMultiplier_arr[3]};
		
		speedOfNodesVaried=${speedOfNodes_arr[3]};
		if [[ $staticOrMobile -eq 0 ]]; then
			runOnce $rowNum $colNum $flowNum $cross_flow $cbr_interval $coverage_coefficient $index_counter $pkts_per_sec;			
		elif [[ $staticOrMobile -eq 1 ]]; then
			runMobileOnce $(($rowNum * $colNum)) $flowNum $pkts_per_sec $speedOfNodesVaried $index_counter $rowNum
		fi
		
		index_counter=$((index_counter + 1));	#idx++
	done
}

varyFlow(){
	#=================Varying flows now =========================
	echo; echo "Now varying flows";

	for (( i = 0; i < $maxVariations; i++ )); do
		#nodeNum=${nodes_arr[$i]};
		rowNum=${rows_arr[2]};
		colNum=${cols_arr[2]};
		flowNum=${flows_arr[$i]};
		pkts_per_sec=${numberOfPacketsPerSec_arr[4]};
		get_cbr_interval "$pkts_per_sec" ;
		cbr_interval=$cbr_interval_from_function;
		coverage_coefficient=${coverageMultiplier_arr[3]};
		speedOfNodesVaried=${speedOfNodes_arr[3]};
		if [[ $staticOrMobile -eq 0 ]]; then
			runOnce $rowNum $colNum $flowNum $cross_flow $cbr_interval $coverage_coefficient $index_counter $pkts_per_sec;			
		elif [[ $staticOrMobile -eq 1 ]]; then
			runMobileOnce $(($rowNum * $colNum)) $flowNum $pkts_per_sec $speedOfNodesVaried $index_counter $rowNum  
		fi

		
		index_counter=$((index_counter + 1));	#idx++
	done
}
varyPacketsPerSec(){
	#=================Varying number of packets_per_sec now =========================
	echo; echo "Now varying number of packets per sec ";
	
	for (( i = 0; i < $maxVariations; i++ )); do
		#nodeNum=${nodes_arr[$i]};
		rowNum=${rows_arr[1]};
		colNum=${cols_arr[1]};
		flowNum=${flows_arr[2]};
		pkts_per_sec=${numberOfPacketsPerSec_arr[$i]};
		get_cbr_interval "$pkts_per_sec" ;
		cbr_interval=$cbr_interval_from_function;
		coverage_coefficient=${coverageMultiplier_arr[3]};
		
		speedOfNodesVaried=${speedOfNodes_arr[$constant_idx]};
		if [[ $staticOrMobile -eq 0 ]]; then
			runOnce $rowNum $colNum $flowNum $cross_flow $cbr_interval $coverage_coefficient $index_counter $pkts_per_sec;			
		elif [[ $staticOrMobile -eq 1 ]]; then
			runMobileOnce $(($rowNum * $colNum)) $flowNum $pkts_per_sec $speedOfNodesVaried $index_counter $rowNum 
		fi
		
		index_counter=$((index_counter + 1));	#idx++
	done
}
varyTransmissionRange(){	
#=================Varying coefficient of transmission_range =========================
	echo; echo "Now varying coefficient of Tx_Range";
	
	for (( i = 0; i < $maxVariations; i++ )); do
		#nodeNum=${nodes_arr[$i]};
		rowNum=${rows_arr[1]};
		colNum=${cols_arr[1]};
		flowNum=${flows_arr[2]};
		pkts_per_sec=${numberOfPacketsPerSec_arr[4]};
		get_cbr_interval "$pkts_per_sec" ;
		cbr_interval=$cbr_interval_from_function;
		coverage_coefficient=${coverageMultiplier_arr[$i]};
		
		runOnce $rowNum $colNum $flowNum $cross_flow $cbr_interval $coverage_coefficient $index_counter $pkts_per_sec
		
		index_counter=$((index_counter + 1));	#idx++
	done

}
varyNodeSpeed(){
#=========================Varying speed of nodes==============================
	echo; echo "Now varying node speed ";
	
	for (( i = 0; i < $maxVariations; i++ )); do
		#nodeNum=${nodes_arr[$i]};
		rowNum=${rows_arr[1]};
		colNum=${cols_arr[1]};
		flowNum=${flows_arr[2]};
		pkts_per_sec=${numberOfPacketsPerSec_arr[4]};
		get_cbr_interval "$pkts_per_sec" ;
		cbr_interval=$cbr_interval_from_function;
		speedOfNodesVaried=${speedOfNodes_arr[$i]};
		runMobileOnce $(($rowNum * $colNum)) $flowNum $pkts_per_sec $speedOfNodesVaried $index_counter $rowNum 

		index_counter=$((index_counter + 1));	#idx++
	done

}
runWirelessTCP_Static(){
	staticOrMobile=0;	#Static
	cross_flow=0;	#For now cross flow is kept at 0 ... all are parallel flows ... 

	echo -e "\n\n ============== Running 802.11 Wireless Static now ... ========================== \n";

	echo -e "\n\n========================= Running 802.11 Wireless Static now ... ============= \n\n" >> "Check.txt";
# echo -e "Hai\nHello\nTesting\n"

	index_counter=1;
	varyNodes
	varyFlow
	varyPacketsPerSec
	varyTransmissionRange

}
runWirelessTCP_Mobile(){
	staticOrMobile=1;	#Mobile
	
	echo -e  "\n===================Running 802.15.4 Wireless Mobile now ... =================\n";
	echo -e "\n\n================ Running 802.15.4 Wireless Mobile now ... ================= \n\n" >> "Check.txt";
 	
 	index_counter=1;
 	varyNodes
 	varyFlow
 	varyPacketsPerSec
 	varyNodeSpeed

}


##################################FUNCTIONS OF AWK WIRELESS_STATIC#####################
indexParsing=1;

metrics_text=('NetworkThroughput.txt' 'EndToEndDelay.txt' 'PacketDeliveryRatio.txt' 'PacketDropRatio.txt' 'EnergyConsumption.txt');


deleteMetricTextFiles_Static(){
	for (( i = 0; i < 5; i++ )); do
		fileToDelete="${nameFile_CSV_toBeUsed[$i]}";
		rm -f "$fileToDelete";
	done
}
allVariationParameters=('');
makeAllVariationParameters(){
	idx=0;
	for (( i = 0; i < $maxVariations; i++ )); do
		allVariationParameters[$idx]=${nodes_arr[$i]};
		idx=$((idx+1));
	done
	for (( i = 0; i < $maxVariations; i++ )); do
		allVariationParameters[$idx]=${flows_arr[$i]};
		idx=$((idx+1));
	done
	for (( i = 0; i < $maxVariations; i++ )); do
		allVariationParameters[$idx]=${numberOfPacketsPerSec_arr[$i]};
		idx=$((idx+1));
	done
	for (( i = 0; i < $maxVariations; i++ )); do
		allVariationParameters[$idx]=${coverageMultiplier_arr[$i]};
		idx=$((idx+1));
	done	
	for (( i = 0; i < $maxVariations; i++ )); do
		allVariationParameters[$idx]=${speedOfNodes_arr[$i]};
		idx=$((idx+1));
	done	

}
runAwk_Mobile(){
	file1="$1";
	file2="$2";
	file3="$3";
	file4="$4";
	file5="$5";

	startingIndexToParse="$6";

	whatParameterIsVaried="$7";
	whatParameterIsVaried=$(($whatParameterIsVaried - 1));
	idxOfVariation=$(($whatParameterIsVaried*$maxVariations));
	#echo "Inside runAwk_Static startingIndexToParse = $startingIndexToParse"
	for (( i = 0; i < $maxVariations; i++ )); do
		
		indexParsing=$(($i + $startingIndexToParse));

		descriptionToPrint=${description_arr_mobile[$(($indexParsing + 0))]};

		get_trace_file $indexParsing
		fileToParse=$trace_file_from_function; 
		changed_var=${allVariationParameters[$idxOfVariation]};
		idxOfVariation=$((idxOfVariation+1));

		echo -e "\n\n============================================================\n\n" >> "Check.txt";		
		echo -e "$indexParsing) $descriptionToPrint" >> "Check.txt";

		awk -v file_throughput="$file1" -v file_delay="$file2" -v file_deliveryRatio="$file3" -v file_dropRatio="$file4" -v file_energyConsumption="$file5" -v valueChanged="$changed_var" -f $awkFileName $trace_file_from_function;
		#echo "awk -v file_throughput="$file1" -v file_delay="$file2" -v file_deliveryRatio="$file3" -v file_dropRatio="$file4" -v file_energyConsumption="$file5" -v valueChanged="$changed_var" -f $awkFileName $trace_file_from_function"; 
		echo; echo;
	done	
}
runAwk_Static(){
	file1="$1";
	file2="$2";
	file3="$3";
	file4="$4";
	file5="$5";

	#deleteMetricTextFiles_Static;
	
	startingIndexToParse="$6";
	whatParameterIsVaried="$7";
	whatParameterIsVaried=$(($whatParameterIsVaried - 1));
	idxOfVariation=$(($whatParameterIsVaried*$maxVariations));
	#echo "Inside runAwk_Static startingIndexToParse = $startingIndexToParse"
	for (( i = 0; i < $maxVariations; i++ )); do
		
		indexParsing=$(($i + $startingIndexToParse));
		get_trace_file $indexParsing
		fileToParse=$trace_file_from_function; 
		changed_var=${allVariationParameters[$idxOfVariation]};
		idxOfVariation=$((idxOfVariation+1));
		
		descriptionToPrint=${description_arr_static[$(($indexParsing + 0))]};


		echo -e "\n\n-------------------------------------------------\n\n" >> "Check.txt";
		echo -e "$indexParsing) $descriptionToPrint" >> "Check.txt";
#echo "Going to run (NOT RUNNING) awk -v file_throughput="$file1" -v file_delay="$file2" -v file_deliveryRatio="$file3" -v file_dropRatio="$file4" -v file_energyConsumption="$file5" -v valueChanged="$changed_var" -f $awkFileName $trace_file_from_function";
		awk -v file_throughput="$file1" -v file_delay="$file2" -v file_deliveryRatio="$file3" -v file_dropRatio="$file4" -v file_energyConsumption="$file5" -v valueChanged="$changed_var" -f $awkFileName $trace_file_from_function;
		#echo "awk -v file_throughput="$file1" -v file_delay="$file2" -v file_deliveryRatio="$file3" -v file_dropRatio="$file4" -v file_energyConsumption="$file5" -v valueChanged="$changed_var" -f $awkFileName $trace_file_from_function;";
		echo; echo;
	done
}


getRequiredCSVFileName(){
	mode="$1";
	i="$2";
	getCSVFolderUsingMode $mode;
	folderCorrect=$csv_folder_returned_from_function;

	predecessorName=${csvFile_arr[$i]};
	for (( j = 0; j < $maxVariations; j++ )); do
		successorName=${metricsMeasured_arr[$j]};
		requiredCSVFile="$folderCorrect$predecessorName$successorName";
		nameFile_CSV_toBeUsed[$j]="$requiredCSVFile";
		#echo "CSV FILE IS <$requiredCSVFile>";
	done
}


runAwkFiles_TCP_Mobile(){
	indexParsing=1;
	echo; echo "Running awk on varying nodes ... "	
	getRequiredCSVFileName 1 0
	#echo "runAwk_Mobile ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 1;"
	runAwk_Mobile ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 1;

	#writeToCSV_VaryingNode 

	indexParsing=6;
	echo ; echo "Running awk on varying flow ... ";
	getRequiredCSVFileName 1 1
	runAwk_Mobile ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 2; 
	#writeToCSV_VaryingFlow
	
	indexParsing=11;
	echo ; echo "Running awk on varying Number of packets per second ... ";
	getRequiredCSVFileName 1 2
	runAwk_Mobile ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 3;
	#writeToCSV_VaryingPacketsPerSecond

	indexParsing=16;
	echo ; echo "Running awk on varying node speed ... ";
	getRequiredCSVFileName 1 4
	runAwk_Mobile ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 4;	
}

runAwkFiles_TCP_Static(){

	indexParsing=1;
	echo; echo "Running awk on varying nodes ... "	
	getRequiredCSVFileName 0 0
	#echo "runAwk_Static ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 1;"
	runAwk_Static ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 1;

	#writeToCSV_VaryingNode 

	indexParsing=6;
	echo ; echo "Running awk on varying flow ... ";
	getRequiredCSVFileName 0 1
	runAwk_Static ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 2; 
	#writeToCSV_VaryingFlow
	
	indexParsing=11;
	echo ; echo "Running awk on varying Number of packets per second ... ";
	getRequiredCSVFileName 0 2
	runAwk_Static ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 3;
	#writeToCSV_VaryingPacketsPerSecond

	indexParsing=16;
	echo ; echo "Running awk on varying Tx_Range ... ";
	getRequiredCSVFileName 0 3
	runAwk_Static ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 4;
	#writeToCSV_VaryingTx_Range
}






awkTest_static(){
	indexParsing=6;
	echo ; echo "Running awk on varying flow ... ";
	getRequiredCSVFileName 0 1
	runAwk_Static ${nameFile_CSV_toBeUsed[0]} ${nameFile_CSV_toBeUsed[1]} ${nameFile_CSV_toBeUsed[2]} ${nameFile_CSV_toBeUsed[3]} ${nameFile_CSV_toBeUsed[4]} $indexParsing 2; 
	#writeToCSV_VaryingFlow
}

#################PLOT GRAPHS FUNCTION#################
plotGraphOnce(){
	#echo "File txt is $textFileReceived and output png file is $outputPNGFile"
	#echo "xAxis: $xAxis , y-axis: $yAxis";
	#echo ;
	if [[ $staticOrMobile -eq 0 ]]; then
		#echo "gnuplot -c "$graphFileName_Static" "$titleOfGraph" "$xAxis" "$yAxis" "$textFileReceived" "$outputPNGFile""
		gnuplot -c "$graphFileName_Static" "$titleOfGraph" "$xAxis" "$yAxis" "$textFileReceived" "$outputPNGFile"
	elif [[ $staticOrMobile -eq 1 ]]; then
		#echo "gnuplot -c "$graphFileName_Static" "$titleOfGraph" "$xAxis" "$yAxis" "$textFileReceived" "$outputPNGFile""
		gnuplot -c "$graphFileName_Static" "$titleOfGraph" "$xAxis" "$yAxis" "$textFileReceived" "$outputPNGFile"
	fi

}
plotGraphMobile(){
	echo "Plotting graphs mobile..."
 	for (( i = 0; i < ${#textFile_arr_mobile[@]}; i++ )); do
		for (( j = 0; j < ${#metricsMeasured_arr[@]}; j++ )); do
			#echo "i = $i, j = $j";
			textFileReceived="$folderOfTextFiles_Mobile${textFile_arr_mobile[$i]}${metricsMeasured_arr[$j]}";
			outputPNGFile="$folderOfTextFiles_Mobile${textFile_arr_mobile[$i]}${pngFiles_arr[$j]}";
			#titleOfGraph="Variation of ${metrics_arr[$j]} against varying ${parameters_arr_mobile[$i]}";
			titleOfGraph="${metrics_arr[$j]} vs ${parameters_arr_mobile[$i]}";
			xAxis="${parameters_arr_mobile[$i]}";
			yAxis="${metrics_arr[$j]}";
			plotGraphOnce "$textFileReceived"
			#echo "text file is : <$textFileReceived>"
		done
		#echo; echo; echo ;
	done
	echo ; echo "Done plotting graphs.."; echo;

}
plotGraphStatic(){
	echo "Plotting graphs static..."
 	for (( i = 0; i < ${#textFile_arr[@]}-1; i++ )); do
		for (( j = 0; j < ${#metricsMeasured_arr[@]}; j++ )); do
			#echo "i = $i, j = $j";
			textFileReceived="$folderOfTextFiles_Static${textFile_arr[$i]}${metricsMeasured_arr[$j]}";
			outputPNGFile="$folderOfTextFiles_Static${textFile_arr[$i]}${pngFiles_arr[$j]}";
			#titleOfGraph="Variation of ${metrics_arr[$j]} against varying ${parameters_arr[$i]}";
			titleOfGraph="${metrics_arr[$j]} vs ${parameters_arr[$i]}";
			xAxis="${parameters_arr[$i]}";
			yAxis="${metrics_arr[$j]}";
			plotGraphOnce "$textFileReceived"
			#echo "text file is : <$textFileReceived>"
		done
		#echo; echo; echo ;
	done
	echo ; echo "Done plotting graphs.."; echo;
}

removeMobileFolder(){
	rm -f 'Mobile_Wireless_TCP/Files/*.tr';
	rm -f 'Mobile_Wireless_TCP/Files/*.nm';
	rm -f 'Mobile_Wireless_TCP/Files/*.txt';


	rm -f 'Mobile_Wireless_TCP/For_Graphs/*.txt';
	rm -f 'Mobile_Wireless_TCP/For_Graphs/*.png';

}

main(){
	noRemove=0;	#0 for remove, 1 for no remove.
	clear ;
	makeAllVariationParameters
	
	if [[ $noRemove -eq 0 ]]; then
		#Remove previous files
		removeDirectories

				#Make new folders
		makeDirectories
	fi

	echo "" > "Check.txt";

	runStatic=1;
	runMobile=1;

	if [[ $runStatic -eq 1 ]]; then
		indexParsing=1;
	#Run for 802.11 static wireless
		runWirelessTCP_Static
	#Run Awk Files to parse things
		description_arr_static_index=1;
		runAwkFiles_TCP_Static;
	#Plot graphs for static mode
		plotGraphStatic;
	fi
	grid_or_rand_mobile=0;
	if [[ $runMobile -eq 1 ]]; then
		#removeMobileFolder ;
		staticOrMobile=1;
		makeCorrectFolder;	#Changes folder to Mobile Folder (Initially Static er Folder)

		indexParsing=1;
	#Run for 802.15.4 mobile wireless
		runWirelessTCP_Mobile;
	#Run Awk Files to parse things
		description_arr_mobile_index=1;
		runAwkFiles_TCP_Mobile;
	#Plot graphs for mobile mode
		plotGraphMobile;
	fi



	
	#Rename Check.txt to Report.txt

	 

}


 
#----------------------------------------------------Run things-------------------------------------






main ;
echo "Main ends...";
#----------------------------------------------------Run things over-----------------------------------
