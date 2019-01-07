
awkFileName="bonusAwk.awk";


#awk -f $awkFileName $traceFileToRun
#awk -v file_perNodethroughput="$file1" -v file_residualEnergy="$file2" -v valueChanged="$changed_var" -f $awkFileName $traceFileToRun;

idxStart=1;	#For vs. nodes
idxStart=6; #For vs. flows
idxStart=11; #For vs. packets per sec
idxStart=16; #For vs. Coverage area TX_Range



#We only vary against packets per sec.

#-----------------------------------------------------Directories-------------------------------------
removeAndMakeDirectories(){
	rm -rf "BonusMetrics_Static/";
	mkdir "BonusMetrics_Static/";
	mkdir "BonusMetrics_Static/Residual Energy/";
	mkdir "BonusMetrics_Static/Per Node Throughput/";
	echo "" > 'Check_Additional.txt';
}


#---------------------------------------------------- Run bonus awk file -------------------------------------


runAwk(){
	idxStart=11;
	for (( i = 1; i <= 20; i++ )); do
		#We only check against packets per second
		#idxToRun=$(($idxStart + $i));
		idxToRun=$i;
		fileName_trace="Wireless_Static_TCP/Files/Trace_$idxToRun.tr";

		file1="BonusMetrics_Static/Residual Energy/Text_$idxToRun.txt";
		
		file2="BonusMetrics_Static/Per Node Throughput/Text_$idxToRun.txt";

		changed_var=$((100 * $(($i + 1)))); #NOT USED IN AWK FILE

		#echo -e "\n\nFor Additonal Parameters in Wireless Static TCP (802.11)\nNodes = 40, Flow = 30, Packets/sec = $packets_per_sec, Cov. area mplier = 4" >> "Check_Additional.txt";
		#echo -e "\nAdditonal Parameters are Residual Energy per node (J) and Per node Throughput in bits/sec\n\n" >> "Check_Additional.txt";
		#echo -e "For Nodes = 40, Flow = 30, Packets/sec = $changed_var, Cov. area mplier = 4\n\n" >> "Check_Additional.txt";
#changed_var is useless here ...
		#echo "awk -v file_perNodethroughput="$file1" -v file_residualEnergy="$file2" -v valueChanged="$changed_var" -f $awkFileName $fileName_trace";
		
		awk -v file_perNodethroughput="$file1" -v file_residualEnergy="$file2" -v valueChanged="$changed_var" -f $awkFileName $fileName_trace;	

		echo -e "\n\n" >> "Check_Additional.txt";
	done
}


description="Nodes = 40, Flow = 30, Packets/sec = $packets_per_sec, Cov. area mplier = 4";

#-------------------------------------------------------------Plot Graph---------------------------------------
plotGraph(){
	echo "NOW PLOTTING GRAPH ... ";
	idxStart=11;
	for (( i = 1; i <= 20; i++ )); do
		#We only check against packets per second
		#idxToRun=$(($idxStart + $i));
		idxToRun=$i;

		file1="BonusMetrics_Static/Residual Energy/Text_$idxToRun.txt";
		file2="BonusMetrics_Static/Per Node Throughput/Text_$idxToRun.txt";
		
		outputPNGFile_residualEnergy="BonusMetrics_Static/Residual Energy/Graph_$idxToRun.png";
		outputPNGFile_perNodeThroughput="BonusMetrics_Static/Per Node Throughput/Graph_$idxToRun.png";	
		changed_var=$((100 * $(($i + 1))));

	#	gnuplot -c "plotGraphs_Static.sh" "$titleOfGraph" "$xAxis" "$yAxis" "$textFileReceived" "$outputPNGFile";


		#PLOT Residual Energy graph
		title1="Residual Energy vs Node";
		packets_per_sec=$changed_var;
		#title1="$description";
		
		gnuplot -c "plotGraphs_Static.sh" "$title1" "Node" "Residual Energy (J)" "$file1" "$outputPNGFile_residualEnergy";

		#Plot per node throughput graph
		title2="Per Node Throughput vs Node";
		#title2=$title1;
		gnuplot -c "plotGraphs_Static.sh" "$title2" "Node" "Throughput (bits/sec)" "$file2" "$outputPNGFile_perNodeThroughput";
	done

}

##################################################################

echo -e "\n\n-----------------------------------------------------------------------------------\n" >> "Check_Additional.txt";
echo -e "Additonal Parameters Per node throughput (bits/sec) and Residual Energy (J) per node is measured in 802.11 static mode with varying packets per second." >> "Check_Additional.txt";
echo -e "\nNodes = 40, Flow = 30, Packets/sec is varied, Cov. area mplier = 4\n\n" >> "Check_Additional.txt";


removeAndMakeDirectories

runAwk

plotGraph

#./queueVariation.sh


