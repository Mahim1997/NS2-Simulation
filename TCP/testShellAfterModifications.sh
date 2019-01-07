#!/bin/bash

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

echo "ns "$tclFileName" $num_row $num_col \
	$parallel_flow $cross_flow \
	$cbr_interval $coefficientOfTxRange \
	$namFileName $traceFileName \
	$topoFileName $x_dim \
	$y_dim $grid_1_random_0 \
	$startTime $time_gap\
	$sizeOFNODE"