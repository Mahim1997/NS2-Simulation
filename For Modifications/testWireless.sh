	clear;


	tclFileName="tcl_wireless_static.tcl";
	num_row=5; num_col=8;	#numNodes=8X5=40
	parallel_flow=20;
	cbr_interval=0.01;	#for 100 packets per sec
	cross_flow=0;
	coefficientOfTxRange=3;	# multiplier

	namFileName="Testing/NamFile.nam";
	topoFileName="Testing/TopoFile.txt";
	traceFileName="Testing/TraceFile.tr";
	grid_1_random_0="1";
	sizeOFNODE=7;
	startTime=100;
	time_gap=50;
	x_dim=1000;
	y_dim=900;


	makeFolder=0;


	if [[ $makeFolder -eq 1 ]]; then
		
		rm -rf Testing/
		mkdir Testing/
	fi

	runStatic=0;

	if [[ $runStatic -eq 1 ]]; then
		ns "$tclFileName" $num_row $num_col \
			$parallel_flow $cross_flow \
			$cbr_interval $coefficientOfTxRange \
			$namFileName $traceFileName \
			$topoFileName $x_dim \
			$y_dim $grid_1_random_0 \
			$startTime $time_gap\
			$sizeOFNODE
	fi



	tclFileName_Mobile="tcl_wireless_mobile.tcl";
	nodeNum=40;
	flowNum=30;
	packetsPerSec=100;
	nodeSpeed=5;
	grid_or_rand_mobile=1;
	ifModified_congestion_mobile=0;
	row=5;
	col=8;

	#Number of Nodes = 40, Flow = 30, Packets per sec = 100, Node speed = 5, row = 5, col = 8


	runMobile=1;
	if [[ $runMobile -eq 1 ]]; then
		clear ;
		#ns $tclFileName_Mobile $nodeNum $flowNum $packetsPerSec $nodeSpeed $namFileName $traceFileName $topoFileName $useModifiedCongestion $grid_or_rand;
		echo "ns $tclFileName_Mobile $nodeNum $flowNum $packetsPerSec $nodeSpeed $namFileName $traceFileName $topoFileName $ifModified_congestion_mobile $grid_or_rand_mobile $row $col";
		echo ;
		ns $tclFileName_Mobile $nodeNum $flowNum $packetsPerSec $nodeSpeed $namFileName $traceFileName $topoFileName $ifModified_congestion_mobile $grid_or_rand_mobile $row $col;
		#exec nam $namFileName ;
	fi




	runAwk=1;


	#clear;
	if [[ $runAwk -eq 1 ]]; then
		#folderName="Testing/Metrics Measured/";
		#mkdir "$folderName";

		file1="Throughput.txt";
		file2="DeliveryRatio.txt";
		file3="DropRatio.txt";
		file4="EnergyConsumption.txt";
		awkFileName="awk_wireless_static.awk";
		trace_file_from_function="Testing/TraceFile.tr";
		changed_var=100;

		echo "awk -v file_throughput="$file1" -v file_delay="$file2" -v file_deliveryRatio="$file3" -v file_dropRatio="$file4" -v file_energyConsumption="$file5" -v valueChanged="$changed_var" -f $awkFileName $trace_file_from_function;";
		echo;
		awk -v file_throughput="$file1" -v file_delay="$file2" -v file_deliveryRatio="$file3" -v file_dropRatio="$file4" -v file_energyConsumption="$file5" -v valueChanged="$changed_var" -f $awkFileName $trace_file_from_function;

	fi

