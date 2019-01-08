BEGIN {
	maximumNodeNumber=-1;
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;
	
	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;

	nDropPackets = 0.0;

	total_energy_consumption = 0;

	temp = 0;
	
	for (i=0; i<max_node; i++) {
		energy_consumption[i] = 0;		
	}

	total_retransmit = 0;
	for (i=0; i<max_pckt; i++) {
		retransmit[i] = 0;		
	}

#For residual energy
	for(nodeIter=0; nodeIter<max_node; nodeIter++){
		checked_initial_total_energy_flag[nodeIter]=0;
		initial_total_energy[nodeIter] = 0;
		residual_energy[nodeIter]=0;
	}
#For per-node throughput
	for(nodeIter=0; nodeIter<max_node; nodeIter++){
		start_time_per_node[nodeIter]=100000;
		end_time_per_node[nodeIter]=0;
		received_bytes_per_node[nodeIter]=0;
	}	


}

{
#	event = $1;    time = $2;    node = $3;    type = $4;    reason = $5;    node2 = $5;    
#	packetid = $6;    mac_sub_type=$7;    size=$8;    source = $11;    dest = $10;    energy=$14;

	strEvent = $1 ;			rTime = $2 ;
	node = $3 ;
	strAgt = $4 ;			idPacket = $6 ;
	strType = $7 ;			nBytes = $8;

	energy = $13;			total_energy = $14;
	idle_energy_consumption = $16;	sleep_energy_consumption = $18; 
	transmit_energy_consumption = $20;	receive_energy_consumption = $22; 
	num_retransmit = $30;
	
	sub(/^_*/, "", node);
	sub(/_*$/, "", node);

	if(node > maximumNodeNumber){
		maximumNodeNumber = node;
	}

	if (energy == "[energy") {
		energy_consumption[node] = (idle_energy_consumption + sleep_energy_consumption + transmit_energy_consumption + receive_energy_consumption);
#		printf("%d %15.5f\n", node, energy_consumption[node]);
#		Shouldn't it be plus ??
	}

	if( 0 && temp <=25 && energy == "[energy" && strEvent == "D") {
		#printf("%s %15.5f %d %s %15.5f %15.5f %15.5f %15.5f %15.5f \n", strEvent, rTime, idPacket, energy, total_energy, idle_energy_consumption, sleep_energy_consumption, transmit_energy_consumption, receive_energy_consumption);
		temp+=1;
	}

	if ( strAgt == "AGT"   &&   strType == "tcp" ) {
		if (idPacket > idHighestPacket) idHighestPacket = idPacket;
		if (idPacket < idLowestPacket) idLowestPacket = idPacket;

		if(rTime > end_time_per_node[node]){
			end_time_per_node[node] = rTime;
		}
		if(rTime < start_time_per_node[node]){
			start_time_per_node[node] = rTime;
		}

		if(rTime>rEndTime) rEndTime=rTime;
		if(rTime<rStartTime) rStartTime=rTime;

		if ( strEvent == "s" ) {
			nSentPackets += 1 ;	rSentTime[ idPacket ] = rTime ;
		}

		if(strEvent == "r" && checked_initial_total_energy_flag[node] == 0){
			checked_initial_total_energy_flag[node] = 1;
			initial_total_energy[node] = total_energy;
			#printf("For node %d, initial energy = %f\n", node, total_energy); 
		}

#		if ( strEvent == "r" ) {
		if ( strEvent == "r" && idPacket >= idLowestPacket) {
			received_bytes_per_node[node] += nBytes;
			nReceivedPackets += 1 ;		nReceivedBytes += nBytes;
#			printf("%15.0f\n", nBytes);
			rReceivedTime[ idPacket ] = rTime ;
			rDelay[idPacket] = rReceivedTime[ idPacket] - rSentTime[ idPacket ];
#			rTotalDelay += rReceivedTime[ idPacket] - rSentTime[ idPacket ];
			rTotalDelay += rDelay[idPacket]; 

#			printf("%15.5f   %15.5f\n", rDelay[idPacket], rReceivedTime[ idPacket] - rSentTime[ idPacket ]);
		}
	}

	if( strEvent == "D"   &&   strType == "tcp" )
	{
		if(rTime>rEndTime) rEndTime=rTime;
		if(rTime<rStartTime) rStartTime=rTime;
		if(rTime > end_time_per_node[node]){
			end_time_per_node[node] = rTime;
		}
		if(rTime < start_time_per_node[node]){
			start_time_per_node[node] = rTime;
		}
		nDropPackets += 1;
	}

	if( strType == "tcp" )
	{
#		printf("%d \n", idPacket);
#		printf("%d %15d\n", idPacket, num_retransmit);
		retransmit[idPacket] = num_retransmit;		
	}
}

END {
	rTime = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / rTime;
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;

	for(i=0; i<max_node;i++) {
#		printf("%d %15.5f\n", i, energy_consumption[i]);
		total_energy_consumption += energy_consumption[i];
	}
	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
		avg_energy_per_packet = total_energy_consumption / nReceivedPackets ;
	}

	if ( nReceivedBytes != 0 ) {
		avg_energy_per_byte = total_energy_consumption / nReceivedBytes ;
		avg_energy_per_bit = avg_energy_per_byte / 8;
	}

	for (i=0; i<max_pckt; i++) {
		total_retransmit += retransmit[i] ;		
#		printf("%d %15.5f\n", i, retransmit[i]);
	}
#Calculating residual energy
	for(i=0; i<maximumNodeNumber; i++){
		residual_energy[i] = initial_total_energy[i] - energy_consumption[i];
	}

#For calculations of throughput
	for(i=0; i<maximumNodeNumber; i++){
		#del_time[i] = end_time_per_node[i] - start_time_per_node[i];
		del_time[i] = rTime;	#Sir bolsilen Full simulation time diya bhag dite
	}
	for(i=0; i<maximumNodeNumber; i++){
		throughput_per_node_bits[i] = (received_bytes_per_node[i] * 8) / (del_time[i]);
		if(start_time_per_node[i] == 100000){
			throughput_per_node_bits[i] = 0;	
		}
	}

printf("Printing residual energy only for nodes which had initial energy\n");
	for(i=0; i<maximumNodeNumber; i++){
		#printf("Node %d, Initial Energy %f, Energy Consumption %f\n", i, initial_total_energy[i], energy_consumption[i]);
		#if(residual_energy[i] > 0){
		if(initial_total_energy[i] > 0){
			printf("Node %d, Initial Energy %f, Energy Consumption %f\n", i, initial_total_energy[i], energy_consumption[i]) >> "Check_Additional.txt";
			printf("Node %d , Residual Energy (J) = %f\n", i, residual_energy[i]) >> "Check_Additional.txt";
			printf("%d %f\n", i, residual_energy[i]) >> file_residualEnergy;
		}
	}

printf("\nNow printing per node throughput in bits per second (ONLY THOSE WITH NON ZERO VALUES)\n");
	for(i=0; i<maximumNodeNumber; i++){
		if(start_time_per_node[i] != 100000 && throughput_per_node_bits[i] > 0){
			#printf("Node %d, StartTime[i] = %f, EndTime[i] = %f\n", i, start_time_per_node[i],
			#end_time_per_node[i]);
			printf("Node %d, del_time = %f\n", i, del_time[i]) >> "Check_Additional.txt";
		printf("Node %d, received bytes per node = %f\n", i, received_bytes_per_node[i]) >> "Check_Additional.txt";
	printf("Node %d, Per-Node Throughput %f bits/sec\n", i, throughput_per_node_bits[i]) >> "Check_Additional.txt";

			printf("Node %d, Per-Node Throughput %f bits/sec\n", i, throughput_per_node_bits[i]);

			printf("%d %f\n", i, throughput_per_node_bits[i]) >> file_perNodethroughput;
			 
		}else{
			#printf("%d 0\n", i) >> file_perNodethroughput;
		}
	}



printf("\n\n\nBONUS things done ... Now printing normal metrics\n\n");
printf( "Throughput: %15.2f \nAverageDelay: %15.5f \nSent Packets: %15.2f \nReceived Packets: %15.2f\
	\nDropped Packets: %15.2f \nPacketDeliveryRatio: %10.2f \nPacketDropRatio: %10.2f\
	\nTotal time: %10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;

	printf("Total_energy: %15.5f \nAvg_enr_per_bit: %15.5f \nAvg_enr_per_byte: %15.5f\
	\nAvg_enr_per_pckt: %15.5f \nTotal_retransmit: %15.0f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit); 
}
