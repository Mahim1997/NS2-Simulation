BEGIN {
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
	

}

{
#	event = $1;    time = $2;    node = $3;    type = $4;    reason = $5;    node2 = $5;    
#	packetid = $6;    mac_sub_type=$7;    size=$8;    source = $11;    dest = $10;    energy=$14;
	
	packID = $12;
	event = $1;
	if(packID == 27){
		printf("\n\nPacket id 27 found .. ");
		printf("\n$1 = %s,\
\n$2 = %s,\
\n$3 = %s,\
\n$4 = %s,\
\n$5 = %s,\
\n$6 = %s,\
\n$7 = %s,\
\n$8 = %s,\
\n$9 = %s,\
\n$10 = %s,\
\n$11 = %s,\
\n$12 = %s", $1 , $2 , $3 , $4 , $5 , $6 , $7 , $8 , $9 , $10 , $11 , $12);
	}	
}

END {


	printf("\n\n\n\n\n");

}
