#!/bin/bash
rm -f *.png;

text_files=('Throughput.txt' 'Drop_Ratio.txt' 'Delivery_Ratio.txt' 'Error_Ratio.txt');
png_files=('Throughput.png' 'Drop_Ratio.png' 'Delivery_Ratio.png' 'Error_Ratio.png');
x_arr=('LinkBandwidth (Mb)' 'Polar Altitutde' 'Orbital Inclination');
y_arr=('Throughput (bits/s)' 'Drop Ratio (%)' 'Delivery Ratio (%)' 'Error Ratio(%)');

title_arr_1=('Throughput ' 'Drop Ratio ' 'Delivery Ratio ' 'Error Ratio ');
title_arr_2=('against Link Bandwidth' 'against Polar Altitutde' 'against Orbital Inclination');



echo "" > "FileOut.txt" ;

for (( i = 0; i < 4; i++ )); do
	idx_const=1;
	xlabel="${x_arr[$idx_const]}";
	ylabel="${y_arr[$i]}";
	title="${title_arr_1[$i]}""${title_arr_2[$idx_const]}";
	textFile="${text_files[$i]}";
	pngFile="${png_files[$i]}";

	c0="set title \"$title\"";
	c1="set xlabel \"$xlabel\"";
	c2="set ylabel \"$ylabel\"";
	c3="set grid";
	c4="plot \"$textFile\" with linespoints title \"$title\"";
	c5="set term png";
	c6="set output \"$pngFile\"";
	#c7="replot";
	echo -e "\n$c0\n$c1\n$c2\n$c3\n$c4\n$c5\n$c6\n" >> "FileOut.txt";

done
