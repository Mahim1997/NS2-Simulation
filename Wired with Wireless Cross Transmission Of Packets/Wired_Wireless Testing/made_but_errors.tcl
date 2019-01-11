	### This simulation is an example of combination of wired and wireless 
	### topologies.
	set sizeNodeWireless 7 ;
	set sizeNodeWired 20;
	set sizeNodeBS 40;


	set start_time 7;
	set time_gap 1;

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
	set num_wired_nodes      [lindex $argv 0];#2 ;	#For simulation we will take this as 1st arg
	set num_bs_nodes         1 ;	#For this we will always use 1 broadcasting node
	set num_wireless_nodes   [lindex $argv 1];#4 ;	#As second arg


	set opt(nn)              $num_wireless_nodes 

	set num_flow_crossXmission			[lindex $argv 2];	#Wired to Wireless flow
	set num_flow_wired			[lindex $argv 3];   #Between wired nodes how many connections ?


	set cbr_size            64 ;	#[lindex $argv 2]; #4,8,16,32,64
	set cbr_rate            11.0Mb;
	set cbr_pckt_rate       [lindex $argv 4];	#Fifth parameter is number of packets per second	
	set cbr_interval		[expr 1.0/$cbr_pckt_rate];	#Auto calculation of 1/packet rate

	set num_connections_with_base	[lindex $argv 5];

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


#	$ns_ node-config -addressType hierarchical
#	AddrParams set domain_num_ 3          
#	lappend cluster_num 2 1 1                
#	AddrParams set cluster_num_ $cluster_num
#	lappend eilastlevel 1 1 4 1              
#	AddrParams set nodes_num_ $eilastlevel 


	# set up for hierarchical routing
	$ns_ node-config -addressType hierarchical
	AddrParams set domain_num_ 2  ;	#Number of domains ... [WE ALWAYS USE 2 , 1 for wired, 1 for wireless and BS]        
	
	lappend cluster_num $num_wired_nodes 1 $num_bs_nodes   ; #Number of clusters ... wired[num_wired], wireless[1], BS [num_bs]
	AddrParams set cluster_num_ $cluster_num
	
	#lappend eilastlevel 1 1 4 1   ; #Number of nodes in each cluster  Wired Wired Wired Wired ... 1 [Wireless] ... BS (BS BS )              
	for {set i 0} {$i < $num_wired_nodes} {incr i} {
		lappend eilastlevel 1 ;
	}
	lappend eilastlevel $num_wireless_nodes ;
	lappend eilastlevel $num_bs_nodes ;

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


#create wired nodes [MAX 30 possible]

#ALLOCATE many wired nodes resources .... 
	set temp {0.0.0 0.1.0 0.2.0 0.3.0 0.4.0 0.5.0 0.6.0 0.7.0 0.8.0 0.9.0 0.10.0 0.11.0 0.12.0 0.13.0 0.14.0 0.15.0 0.16.0 0.17.0 0.18.0 0.19.0 0.20.0 0.21.0 0.22.0 0.23.0 0.24.0 0.25.0 0.26.0 0.27.0 0.28.0 0.29.0 0.30.0};
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


#Again for wireless nodes, create many resources using cluster 1... [MAX 101 here]
#1.0.0 is for Base Node BS, rest 1.0.1 to ... 1.0.101 are for wireless nodes (100 wireless nodes)
	set temp {1.0.0 1.0.1 1.0.2 1.0.3 1.0.4 1.0.5 1.0.6 1.0.7 1.0.8 1.0.9 1.0.10 1.0.11 1.0.12 1.0.13 1.0.14 1.0.15 1.0.16 1.0.17 1.0.18 1.0.19 1.0.20 1.0.21 1.0.22 1.0.23 1.0.24 1.0.25 1.0.26 1.0.27 1.0.28 1.0.29 1.0.30 1.0.31 1.0.32 1.0.33 1.0.34 1.0.35 1.0.36 1.0.37 1.0.38 1.0.39 1.0.40 1.0.41 1.0.42 1.0.43 1.0.44 1.0.45 1.0.46 1.0.47 1.0.48 1.0.49 1.0.50 1.0.51 1.0.52 1.0.53 1.0.54 1.0.55 1.0.56 1.0.57 1.0.58 1.0.59 1.0.60 1.0.61 1.0.62 1.0.63 1.0.64 1.0.65 1.0.66 1.0.67 1.0.68 1.0.69 1.0.70 1.0.71 1.0.72 1.0.73 1.0.74 1.0.75 1.0.76 1.0.77 1.0.78 1.0.79 1.0.80 1.0.81 1.0.82 1.0.83 1.0.84 1.0.85 1.0.86 1.0.87 1.0.88 1.0.89 1.0.90 1.0.91 1.0.92 1.0.93 1.0.94 1.0.95 1.0.96 1.0.97 1.0.98 1.0.99 1.0.100 1.0.101};

	#set temp {1.0.0 1.0.1 1.0.2 1.0.3 1.0.4}  ; ## FOR WIRELESS NODES  


	set BS(0) [$ns_ node [lindex $temp 0]] ; # 1.0.0 is the base node 
	
	$BS(0) random-motion 0 


	$BS(0) set X_ 10.0
	$BS(0) set Y_ 20.0
	$BS(0) set Z_ 0.0

	#configure for wireless nodes
	set val(energymodel_11)    			EnergyModel     ;
	set val(initialenergy_11)  			1000            ;# Initial energy in Joules
	set val(idlepower_11) 				900e-3			;#Stargate (802.11b) 
	set val(rxpower_11) 				925e-3			;#Stargate (802.11b)
	set val(txpower_11) 				1425e-3			;#Stargate (802.11b)
	set val(sleeppower_11) 				300e-3			;#Stargate (802.11b)
	set val(transitionpower_11) 		200e-3			;#Stargate (802.11b)	??????????????????????????????/
	set val(transitiontime_11) 			3				;#Stargate (802.11b)

	$ns_ node-config -wiredRouting OFF -movementTrace ON \
						-energyModel $val(energymodel_11) \
						-idlePower $val(idlepower_11) \
						-rxPower $val(rxpower_11) \
						-txPower $val(txpower_11) \
							 -sleepPower $val(sleeppower_11) \
							 -transitionPower $val(transitionpower_11) \
						-transitionTime $val(transitiontime_11) \
						-initialEnergy $val(initialenergy_11)



	for {set j 0} {$j < $opt(nn)} {incr j} {
		set node_($j) [ $ns_ node [lindex $temp \
		        [expr $j+1]] ]
		$node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]]
	}

############################## Create Links Between Wired nodes and BS node ############
	#create links between wired and BS nodes
	#$ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail
	#$ns_ duplex-link $W(1) $BS(0) 15Mb 10ms DropTail


	#$ns_ duplex-link-op $W(0) $W(1) orient down
	#$ns_ duplex-link-op $W(1) $BS(0) orient left-down

	for {set i 0} {$i < $num_flow_wired} {incr i} {
		set wiredNode1_idx [expr int($num_wired_nodes*rand())];
		set wiredNode2_idx [expr int($num_wired_nodes*rand())];
	
		#Randomly choose two DIFFERENT wired nodes ...
		while {$wiredNode1_idx == $wiredNode2_idx} {
			set wiredNode1_idx [expr int($num_wired_nodes*rand())];
			set wiredNode2_idx [expr int($num_wired_nodes*rand())];
		}
		$ns_ duplex-link $W($wiredNode1_idx) $W($wiredNode2_idx) 5Mb 2ms DropTail ; #Between each nodes ...
	}

#### Now connect with base node ...
##OBVIOUSLY we want num_connections_with_base <= $num_wired_nodes 

##IF not , we set it like that
	if {$num_connections_with_base > $num_wired_nodes} {
		#Then set equal to ... 
		set num_connections_with_base $num_wired_nodes ;
	}

#### Now set connection with wired(i) node to base station ...
	for {set i 0} {$i < $num_connections_with_base} {incr i} {
		$ns_ duplex-link $W($i) $BS(0) 15Mb 10ms DropTail ;

	}



################################## Create Links Between Wired nodes and BS node done ############



############################################## WIRELESS NODE POSITIONING #######################################


###Grid positioning ... 
	set counter_col 0;
	set up_partition 30.0;
	for {set i 0} {$i < $num_wireless_nodes} {incr i} {
		#setting positions of wireless nodes ....
		set c [expr $i%4];
		set z_pos 0.0;
		set y_pos [expr 0.0+$counter_col*$up_partition];
		if {$c == 0} {
			set x_pos -50.0;
		}
		if {$c == 1} {
			set x_pos 0.0;
		}
		if {$c == 2} {
			set x_pos 50.0; 
		}
		if {$c == 3} {
			set x_pos 100.0
		}
		$node_($i) set X_ x_pos;
		$node_($i) set Y_ y_pos;
		$node_($i) set Z_ z_pos;

		set counter_col [expr $counter_col+1];
	}

############################################## WIRELESS NODE POSITIONING done #######################################


############################################# Set up connections #################################
####Random flow 

for {set flow_cnt_iter 0} {$flow_cnt_iter < $num_flow_crossXmission} {incr flow_cnt_iter} {
	set tcp [new Agent/TCP];
	$tcp set class_ 2;
	set sink [new Agent/TCPSink];

	set wiredNodeFoud [expr int($num_wired_nodes*rand())] ; #Always between [0, num_wired_nodes)
	set wirelessNodeFound [expr int($num_wireless_nodes*rand())] ; #Always betn [0, num_wireless_nodes)

	$ns_ attach-agent $W($wiredNodeFoud) $tcp ;
	$ns_ attach-agent $node_($wirelessNodeFound) $sink ;

	$ns_ connections $tcp $sink ;

	set cbr [new Application/Traffic/CBR]
	$cbr set packetSize_ $cbr_size
	$cbr set rate_ $cbr_rate
	$cbr set interval_ $cbr_interval
	$cbr attach-agent $tcp 
	#$ns_ at $start_time "$cbr start"
	$ns_ at [expr $start_time+$i*$time_gap] "$cbr start"
}




######################################## Set up connections done ##############################
 


########################################### COLOR THE NODES #########################################

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

########################################### COLOR THE NODES done #########################################


############################################ Set initial size of nodes #####################################
	for {set i 0} {$i < $opt(nn)} {incr i} {
	  $ns_ initial_node_pos $node_($i) $sizeNodeWireless
	}

	for {set i 0} {$i < $num_wired_nodes} {incr i} {
		#$ns_ initial_node_pos $W($i) $sizeNodeWired
	}
	for {set i 0} {$i < $num_bs_nodes} {incr i} {
		#$ns_ initial_node_pos $BS($i) $sizeNodeBS
	}

############################################ Set initial size of nodes done #####################################


########################## FINISH 




####################


################################## Run sim #################################
	for {set i } {$i < $opt(nn) } {incr i} {
	  $ns_ at $opt(stop).0000010 "$node_($i) reset";
	}
	
	$ns_ at $opt(stop).0000010 "$BS(0) reset";

#$ns_ at $opt(stop).40 "finish"

	$ns_ at $opt(stop).1 "puts \"NS EXITING...\" ; $ns_ halt"

	puts "Starting Simulation..."
	$ns_ run


################################## Run sim done #################################