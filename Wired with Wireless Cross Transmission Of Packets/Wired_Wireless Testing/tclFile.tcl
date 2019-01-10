	### This simulation is an example of combination of wired and wireless 
	### topologies.
	set sizeNodeWireless 7 ;
	set sizeNodeWired 20;
	set sizeNodeBS 40;

	global opt
	set opt(chan)       Channel/WirelessChannel
	set opt(prop)       Propagation/TwoRayGround
	set opt(netif)      Phy/WirelessPhy
	set opt(mac)        Mac/802_11
	set opt(ifq)        Queue/DropTail/PriQueue
	set opt(ll)         LL
	set opt(ant)        Antenna/OmniAntenna
	set opt(x)          500   
	set opt(y)          500   
	set opt(ifqlen)         50   
	set opt(tr)          wired-and-wireless.tr
	set opt(namtr)       wired-and-wireless.nam
	                  
	set opt(adhocRouting)   DSDV;		#AODV doesn't work for some reason ??                      
	set opt(cp)             ""                        
	#set opt(sc)             "scen-3-test"   
	set opt(stop)           300                           
	set num_wired_nodes      2
	set num_bs_nodes         2
	set num_wireless_nodes   4


	set opt(nn)              $num_wireless_nodes 


###################################TO ADD MOBILITY###################################



## Setting The Distance Variables..
# For model 'TwoRayGround'
      set dist(5m)  7.69113e-06
      set dist(9m)  2.37381e-06
      set dist(10m) 1.92278e-06
      set dist(11m) 1.58908e-06
      set dist(12m) 1.33527e-06
      set dist(13m) 1.13774e-06
      set dist(25m) 3.07645e-07
      set dist(30m) 2.13643e-07
      set dist(35m) 1.56962e-07
      set dist(40m) 1.56962e-10
      set dist(45m) 1.56962e-11
      set dist(50m) 1.20174e-13
      Phy/WirelessPhy set CSThresh_ $dist(50m)
      Phy/WirelessPhy set RXThresh_ $dist(50m)

######################################################################################

	set ns_   [new Simulator];





	# set up for hierarchical routing
	$ns_ node-config -addressType hierarchical
	AddrParams set domain_num_ 3          
	lappend cluster_num 2 1 1                
	AddrParams set cluster_num_ $cluster_num
	lappend eilastlevel 1 1 4 1              
	AddrParams set nodes_num_ $eilastlevel 



	############TRACE AND NAM FILES####################
	set trace_file  [open $opt(tr) w]
	$ns_ trace-all $trace_file
	set namtrace_file [open $opt(namtr) w]
	$ns_ namtrace-all $namtrace_file


	set topo   [new Topography]
	$topo load_flatgrid $opt(x) $opt(y)
	# god needs to know the number of all wireless interfaces
	create-god [expr $opt(nn) + $num_bs_nodes]

	######################################################



	#create wired nodes
	set temp {0.0.0 0.1.0}
	#set temp {0.0.0 0.1.0 0.2.0}        
	for {set i 0} {$i < $num_wired_nodes} {incr i} {
	  set W($i) [$ns_ node [lindex $temp $i]]
	} 
	$ns_ node-config -adhocRouting $opt(adhocRouting) \
	             -llType $opt(ll) \
	             -macType $opt(mac) \
	             -ifqType $opt(ifq) \
	             -ifqLen $opt(ifqlen) \
	             -antType $opt(ant) \
	             -propInstance [new $opt(prop)] \
	             -phyType $opt(netif) \
	             -channel [new $opt(chan)] \
	             -topoInstance $topo \
	             -wiredRouting ON \
	             -agentTrace ON \
	             -routerTrace OFF \
	             -macTrace OFF

	set temp {1.0.0 1.0.1 1.0.2 1.0.3 1.0.4}  ; ## FOR WIRELESS NODES  
#	set temp {1.0.0 1.0.1 1.0.2 1.0.3}

	set BS(0) [$ns_ node [lindex $temp 0]]
	set BS(1) [$ns_ node 2.0.0]
	
	$BS(0) random-motion 0 
	$BS(1) random-motion 0

	$BS(0) set X_ 10.0
	$BS(0) set Y_ 20.0
	$BS(0) set Z_ 0.0

	$BS(1) set X_ 100.0
	$BS(1) set Y_ 100.0
	$BS(1) set Z_ 0.0

	#configure for mobilenodes
	$ns_ node-config -wiredRouting OFF -movementTrace ON 


	for {set j 0} {$j < $opt(nn)} {incr j} {
	set node_($j) [ $ns_ node [lindex $temp \
	        [expr $j+1]] ]
	$node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]]
	}
	#create links between wired and BS nodes
	$ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail
	#$ns_ duplex-link $W(0) $W(2) 5Mb 2ms DropTail
	#$ns_ duplex-link $W(1) $W(2) 5Mb 2ms DropTail
	
	$ns_ duplex-link $W(1) $BS(0) 15Mb 10ms DropTail
	$ns_ duplex-link $W(1) $BS(1) 15Mb 10ms DropTail
	#$ns_ duplex-link $W(2) $BS(0) 15Mb 10ms DropTail	

	$ns_ duplex-link-op $W(0) $W(1) orient down
	$ns_ duplex-link-op $W(1) $BS(0) orient left-down
	$ns_ duplex-link-op $W(1) $BS(1) orient right-down


	#for {set i 0} {$i < $opt(nn)} {incr i} {
	#  $node_($i) set X_ [expr 50+($i*20)];
	#  $node_($i) set Y_ [expr 40+($i*25)];
	#  $node_($i) set Z_ 0;
	#}


############################################## WIRELESS NODE POSITIONING #######################################

	$node_(0)	set X_ 0.0;
	$node_(0)	set Y_ 0.0;
	$node_(0)	set Z_ 0.0;

	$node_(1)	set X_ -40.0;
	$node_(1)	set Y_ 0.0;
	$node_(1)	set Z_ 0.0;

	$node_(2)	set X_ 50.0;
	$node_(2)	set Y_ 0.0;
	$node_(2)	set Z_ 0.0;

	$node_(3)	set X_ 100.0;
	$node_(3)	set Y_ 0.0;
	$node_(3)	set Z_ 0.0;

############################################## WIRELESS NODE POSITIONING #######################################

########Movements 

set will_move 0
set double_move 1
set nodeSpeed 5
####################### MOVEMENT ############################
if {$will_move == 1} {
	$ns_ at 70.0 "$node_(0) setdest 200.0 100.0 $nodeSpeed";
	$ns_ at 60.0 "$node_(1) setdest 100.0 100.0 $nodeSpeed";
	$ns_ at 50.0 "$node_(2) setdest 200.0 200.0 $nodeSpeed";
	$ns_ at 65.0 "$node_(3) setdest 100.0 200.0 $nodeSpeed";

	if {$double_move == 1} {
		$ns_ at 110.0 "$node_(0) setdest 200.0 200.0 $nodeSpeed";	
		$ns_ at 100.0 "$node_(1) setdest 300.0 300.0 $nodeSpeed";
		$ns_ at 140.0 "$node_(2) setdest 300.0 200.0 $nodeSpeed";
		$ns_ at 150.0 "$node_(3) setdest 200.0 300.0 $nodeSpeed";

	}
}

####################### MOVEMENT ############################


	# setup TCP connections
	set tcp1 [new Agent/TCP]
	$tcp1 set class_ 2
	set sink1 [new Agent/TCPSink]
	#$ns_ attach-agent $node_(0) $tcp1
	#$ns_ attach-agent $W(0) $sink1

	$ns_ attach-agent $W(0) $tcp1
	$ns_ attach-agent $node_(0) $sink1
	
	$ns_ connect $tcp1 $sink1
	set ftp1 [new Application/FTP]
	$ftp1 attach-agent $tcp1
	#$ns_ at 160 "$ftp1 start"
	$ns_ at 20 "$ftp1 start"



	set tcp2 [new Agent/TCP]
	$tcp2 set class_ 2
	set sink2 [new Agent/TCPSink]
	$ns_ attach-agent $W(1) $tcp2
	$ns_ attach-agent $node_(2) $sink2
	$ns_ connect $tcp2 $sink2
	set ftp2 [new Application/FTP]
	$ftp2 attach-agent $tcp2
	$ns_ at 25 "$ftp2 start"
	#$ns_ at 180 "$ftp2 start"

	##FLOW BETWEEN Wired 1 and wireless 3
	set tcp3 [new Agent/TCP]
	$tcp3 set class_ 2
	set sink3 [new Agent/TCPSink]
	$ns_ attach-agent $W(1) $tcp3 
	$ns_ attach-agent $node_(3) $sink3
	$ns_ connect $tcp3 $sink3
	set ftp3 [new Application/FTP] 
	$ftp3 attach-agent $tcp3 
	$ns_ at 35 "$ftp3 start"




	set tcp4 [new Agent/TCP]
	$tcp4 set class_ 2
	set sink4 [new Agent/TCPSink]
	$ns_ attach-agent $W(0) $tcp4 
	$ns_ attach-agent $node_(1) $sink4
	$ns_ connect $tcp4 $sink4
	set ftp4 [new Application/FTP] 
	$ftp4 attach-agent $tcp4 
	$ns_ at 15 "$ftp4 start"




for {set i 0} {$i < $num_wired_nodes} {incr i} {
    #$W($i) color blue ;
    $W($i) color "#00FF00";
}

#Color base station as red
for {set i 0} {$i < $num_bs_nodes} {incr i} {
    $BS($i) color red ;
}

for {set i 0} {$i < $num_wireless_nodes} {incr i} {
	#$ns_ at 0.0 "$node_($i) color blue"
	#$node_($i) color "blue";
	$node_($i) color blue
    $ns_ at 0.0 "$node_($i) color blue"
    #$node_($i) color "#0000FF"; #R G B
}

	for {set i 0} {$i < $opt(nn)} {incr i} {
	  $ns_ initial_node_pos $node_($i) $sizeNodeWireless
	}

	for {set i 0} {$i < $num_wired_nodes} {incr i} {
		#$ns_ initial_node_pos $W($i) $sizeNodeWired
	}
	for {set i 0} {$i < $num_bs_nodes} {incr i} {
		#$ns_ initial_node_pos $BS($i) $sizeNodeBS
	}
	#Color wired nodes as green



	for {set i } {$i < $opt(nn) } {incr i} {
	  $ns_ at $opt(stop).0000010 "$node_($i) reset";
	}
	
	$ns_ at $opt(stop).0000010 "$BS(0) reset";

	$ns_ at $opt(stop).1 "puts \"NS EXITING...\" ; $ns_ halt"

	puts "Starting Simulation..."
	$ns_ run


