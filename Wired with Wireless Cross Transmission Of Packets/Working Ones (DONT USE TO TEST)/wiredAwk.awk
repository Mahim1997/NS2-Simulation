BEGIN {
# types of traces found ...

#COLS:
#1  2     3  4   5   6     7    8  9    10  11  12   13      14    15      16
#+ 1.0000 66 26 cbr 210 ------- 0 66.0 67.0  0  0   37.90 -122.30 48.90 -120.94		ENQUEUED

#1       2    3  4  5   6     7    8   9  10   11  12
#r 10.263272 17 16 cbr 210 ------- 0 19.0 16.0 0   1   							RECEIVED

#+ 61.0100 12 11 cbr 210 ------- 0 12.0 13.0 1 2 37.90 -122.30 0.00 -100.00		ENQUEUED

#- 61.0100 12 11 cbr 210 ------- 0 12.0 13.0 1 2 37.90 -122.30 0.00 -100.00		DEQUEUED

#e 12.2404 12 13 cbr 210 ------- 0 12.0 13.0 0 0 10.00 -130.20 0.00 -100.00			ERROR

#d 848.0000 14 -2 cbr 210 ------- 1 14.0 15.0 6 21 0.00 10.00 -999.00 -999.00		DROPPED
	numNodes = 0;
	MAX = 1000;
	startTime = MAX;
	endTime = 0;

	for(i=0; i<MAX; i++){
		latitudes[i] = -1;
		longitudes[i] = -2;

		per_node_throughput[i] = 0;

		queue_size_bytes[i] = 0;
		queue_size_packets[i] = 0;

		number_packets_sent[i] = 0;
		number_packets_received[i] = 0;
		number_packets_dropped[i] = 0;
		number_packets_error[i] = 0;


		number_bytes_sent[i] = 0;
		number_bytes_received[i] = 0;
		number_bytes_dropped[i] = 0;
		number_bytes_error[i] = 0;



		flag_exists[i] = 0;
	}

	total_packets_sent = 0;
	total_packets_received = 0;
	total_packets_dropped = 0;
	total_packets_error = 0;

	total_bytes_sent = 0;
	total_bytes_received = 0;
	total_bytes_dropped = 0;
	total_bytes_error = 0;

	printf("INSIDE Wired's AWK FILE!\n");
	skip1 = 0;
	skip2 = 0;
}

{
	eventType = $1;
	time = $2;
	node = $3;
	destNode = $4;
	packetType = $5; #eg. cbr
	packetSize = $6; # in bytes


	packet_id = $12; # ??

	latitude_source = -1;
	longitude_source = -1;

	latitude_dest = -1;
	longitude_dest = -1;	

	latitudes[node] = latitude_source;
	longiudes[node] = longitude_source;
	flag_exists[node] = 1;

#	printf("LINE 81, node = %d\n", node);


	if(startTime > time){
		startTime = time;
	}
	if(time > endTime){
		endTime = time;
	}

	if(latitude_dest != -999.00 && destNode != -2){
		latitudes[destNode] = latitude_dest;
		longitudes[destNode] = longitude_dest;
		flag_exists[destNode] = 1;
	}
	if(eventType == "+"){
		queue_size_bytes[node] += packetSize;
		outputFile1 = "Output" + node + ".txt";
		
		queue_size_packets[node] ++ ;

		printf("%f %f\n",time, queue_size_bytes[node]) >> outputFile1 ;
		

		
	}
	else if(eventType == "-"){
		queue_size_bytes[node] -= packetSize; 
		queue_size_packets[node] --;

		number_packets_sent[node]++;
		number_bytes_sent[node] += packetSize;

		total_packets_sent++;
		total_bytes_sent += packetSize;
		outputFile1 = "Output" + node + ".txt";
		
		printf("%f %f\n",time, queue_size_bytes[node]) >> outputFile1 ;
	
		
	}
	else if(eventType == "r"){
		_15th_col = $15;
		if(_15th_col == ""){
			number_packets_received[node]++ ;
			number_bytes_received[node] += packetSize;

			total_packets_received++;
			total_bytes_received += packetSize;
		}	
	}
	else if(eventType == "d"){
		number_packets_dropped[node]++;
		number_bytes_dropped[node] += packetSize;

		total_packets_dropped++;
		total_bytes_dropped += packetSize;
	}
	else if(eventType == "e"){
		number_packets_error[node]++;
		number_bytes_error[node] += packetSize;

		total_packets_error++;
		total_bytes_error += packetSize;		
	}
	else{
		#Ignore
	}

}

END {
	for(i=0; i<MAX; i++){
		if(flag_exists[i] == 1){
			numNodes++;
		}
	}


	#printf("Printing Latitudes and Longitudes of the %d nodes\n\n", numNodes);
	for(i=0; i<MAX; i++){
		if(flag_exists[i] == 1){
			#printf("Node : %d, Latitude : %0.4f, Longitude : %.4f\n", i, latitudes[i], longitudes[i]);
			#printf("Node %3d  <%0.4f, %0.4f>\n", i, latitudes[i], longitudes[i]);
		}
	}


	printf("\nPrinting Total Metrics, Total Number of nodes = %d\n", numNodes);


	printf("\nTotal Number of packets sent = %d, bytes sent = %0.2f\n", total_packets_sent, total_bytes_sent);
	printf("Total Number of packets received = %d, bytes received = %0.2f\n", total_packets_received, total_bytes_received);
	printf("Total Number of packets dropped = %d, bytes dropped = %0.2f\n", total_packets_dropped, total_bytes_dropped);
	printf("Total Number of error packets = %d, error bytes = %0.2f\n", total_packets_error, total_bytes_error);
	
	dropRatio = ( total_bytes_dropped / total_bytes_sent ) * 100 ;
	deliveryRatio = ( total_bytes_received / total_bytes_sent ) * 100;
	errorRatio = ( total_bytes_error / total_bytes_sent ) * 100;

	total_throughput = total_bytes_received / (endTime - startTime);  # in bytes
	total_throughput = total_throughput * 8;

	printf("Start time = %d, End Time = %d\n", startTime, endTime);

	printf("\nDelivery Ratio = %0.2f percent \nDrop Ratio = %0.2f percent\nError ratio = %0.2f percent\n", 
	deliveryRatio, dropRatio, erroRatio);

	printf("Total Throughput = %0.2f bits/sec \n", total_throughput);

	printf("\n\n\n");
}




