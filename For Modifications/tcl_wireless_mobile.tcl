#-------------------------------Step 1. Set values of parameters-------------------------------#

#1a. Network size
	set gridArrangedOrRandomArranged [lindex $argv 8];	#1 for Grid, 0 for Random

	set grid_x_dim			500 ;	#[lindex $argv 1]
	set grid_y_dim          500 ;	#[lindex $argv 1]

#1b. Number and positioning and speed of nodes [Taken from shell script]
	set num_node            [lindex $argv 0];	#First parameter is number of nodes..	 
	set node_speed			[lindex $argv 3];	#Fourth parameter is node speed..

#1c. Number and other attributes of flows. [Taken from script]
	set num_flow			[lindex $argv 1];	#Second parameter is flow..
	set cbr_size            64 ;	#[lindex $argv 2]; #4,8,16,32,64
	set cbr_rate            11.0Mb

	set time_duration       15 ;	#[lindex $argv 5] ;#50
	set start_time          1
	set extra_time          30; 	# was 5
	set flow_start_gap      0.0
	set motion_start_gap    0.05
	set cbr_pckt_rate       [lindex $argv 2];	#Third parameter is number of packets per second	
	set cbr_interval		[expr 1.0/$cbr_pckt_rate];	#Auto calculation of 1/packet rate

#1d. Energy parameters
	set val(energymodel)	EnergyModel;
	set val(initialenergy)	1000;	#Initial energy is 1000 Joules	

	set dist(5m)  7.69113e-06
	set dist(9m)  2.37381e-06
	set dist(10m) 1.92278e-06
	set dist(11m) 1.58908e-06
	set dist(12m) 1.33527e-06
	set dist(13m) 1.13774e-06
	set dist(14m) 9.81011e-07
	set dist(15m) 8.54570e-07
	set dist(16m) 7.51087e-07
	set dist(20m) 4.80696e-07
	set dist(25m) 3.07645e-07
	set dist(30m) 2.13643e-07
	set dist(35m) 1.56962e-07
	set dist(40m) 1.20174e-07
	Phy/WirelessPhy set CSThresh_ $dist(40m)
	Phy/WirelessPhy set RXThresh_ $dist(40m)

#1e. Protocols and models for different layers

	#set source_type		Agent/UDP;	#Agent for UDP
	#set sink_type			Agent/Null;	#Agent for UDP

	set source_type			Agent/TCP;	#Using TCP Agent 
	set sink_type			Agent/TCPSink; #Using TCP Agent

	set doWeUseModifiedCongestion [lindex $argv 7]; #If this is 1.. then use the next argument for congestion control mechanism modified.
	
	if {$doWeUseModifiedCongestion == 1} {
		#Yes we do use modified method ..
		set newCase_forModification 9;		#Case 9 was modified in opencwnd()
		$source_type set windowOption_ $newCase_forModification; #For Congestion Control Case 9 or Case 10 (MODIFIED)
	}

	set val(chan)						Channel/WirelessChannel 	;# channel type
	set val(prop) 						Propagation/TwoRayGround 	;# radio-propagation model
	#set val(prop) Propagation/FreeSpace ;# radio-propagation model
	set val(netif) 						Phy/WirelessPhy/802_15_4 	;# network interface type
	set val(mac) 						Mac/802_15_4				;# MAC type
	set val(ifq) 						Queue/DropTail/PriQueue 	;# interface queue type
	set val(ll) 						LL 							;# link layer type
	set val(ant) 						Antenna/OmniAntenna 		;# antenna model
	set val(ifqlen) 					100							;# max packet in ifq
	set val(rp) 						AODV						;#DSDV 						;# routing protocol
	set val(nn)							$num_node					;# number of mobile nodes


###############################################STEP 1 done##############################################


#-------------------------------Step 2. Initialize ns -------------------------------#

	set ns_ [new Simulator]

###############################################STEP 2 done##############################################



#-------------------------------Step 3. Open required files -------------------------------#

	set nam_file_name		[lindex $argv 4]; #Fourth parameter is name of nam file.
	set trace_file_name		[lindex $argv 5]; #Fifth param is name of trace file.
	set topo_file_name		[lindex $argv 6]; #Sixth param is name of topology file.

	# setup trace support by opening the trace file
	set tracefd     [open $trace_file_name w]
	$ns_ trace-all $tracefd

	# setum nam (Network Animator) support by opening the nam file
	set namtrace    [open $nam_file_name w]
	$ns_ namtrace-all-wireless $namtrace $grid_x_dim $grid_y_dim


	# create a topology object that keeps track of movements...
	# ...of mobile nodes within the topological boundary.
	set topo_file   [open $topo_file_name "w"]


	set topo	[new Topography]
	$topo load_flatgrid $grid_x_dim $grid_y_dim
	# Grid resolution can be passed to load_flatgrid as a 3rd parameter.
	# Default is 1.

	# create the object God
	create-god $val(nn)

###############################################STEP 3 done##############################################


#-------------------------- Step 4.Node configuration ---------------------------------#

	$ns_ node-config	-adhocRouting $val(rp) \
						-llType $val(ll) \
		     			-macType $val(mac)  \
						-ifqType $val(ifq) \
		     			-ifqLen $val(ifqlen) \
						-antType $val(ant) \
		     			-propType $val(prop) \
						-phyType $val(netif) \
		     			-channel  [new $val(chan)] \
						-topoInstance $topo \
		     			-agentTrace ON \
						-routerTrace OFF\
		     			-macTrace ON \
		     			-movementTrace OFF \
	             		-energyModel $val(energymodel) \
	             		-initialEnergy $val(initialenergy) \
	             		-rxPower 35.28e-3 \
	             		-txPower 31.32e-3 \
		     			-idlePower 712e-6 \
		     			-sleepPower 144e-9




###############################################STEP 4 done##############################################

 

#-------------------------- Step 5. Create Nodes with positioning ---------------------------------#
puts "Start node creation"

set num_row [lindex $argv 9] ;
set num_col [lindex $argv 10];
puts "INSIDE TCL FILE gridArrangedOrRandomArranged = $gridArrangedOrRandomArranged, num_row = $num_row, and num_col = $num_col";

if { $gridArrangedOrRandomArranged == 1 } {
	#GRID TOPOPLOGY
	puts "Grid Topology";

 
	set i 0;
	set counter 0;


	set x_start [expr int($grid_x_dim/($num_col*2))];
	set y_start [expr int($grid_y_dim/($num_row*2))];
	puts "==--->>>>> INSIDE TCL FILE ... x_start = $x_start and y_start = $y_start";

	while {$i < $num_row } {
	#in same column
	    for {set j 0} {$j < $num_col } {incr j} {
		#in same row
			set m [expr int( $i*$num_col+$j )];
			set node_($m) [$ns_ node] ;
		#	$node_($m) set X_ [expr $i*240];
		#	$node_($m) set Y_ [expr $k*240+20.0];
		#CHNG
			set my_x [expr int($x_start*2)];
			set my_y [expr int($y_start*2)];

			#puts "$counter. my_x = $my_x, my_y = $my_y";

			set x_pos [expr int($x_start+$j*$my_x)];#grid settings
			set y_pos [expr int($y_start+$i*$my_y)];#grid settings
			
#			set x_pos [expr int($x_start+$j*($grid_x_dim/$num_col))];#grid settings
#			set y_pos [expr int($y_start+$i*($grid_y_dim/$num_row))];#grid settings

			puts "-->>>$counter) my_x = $my_x, my_y = $my_y,  x_pos = $x_pos, y_pos = $y_pos";

			set nowIndex [expr $i*$num_col + $j];
			
			set positions_of_x($counter) $x_pos;
			set positions_of_y($counter) $y_pos;

			#puts "Updating at positions_of_x ($nowIndex) = $x_pos, and positions_of_y ($i) = $y_pos, counter = $counter";
			#set counter [expr $counter + 1];
			incr counter;
			
			$node_($m) random-motion 0
			$node_($m) set X_ $x_pos;
			$node_($m) set Y_ $y_pos;
			$node_($m) set Z_ 0.0
		#	puts "$m"
			puts -nonewline $topo_file "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
	    }
	    incr i;
	};
	
} else {
	puts "Random Topology";
	for {set i 0} {$i < $num_node} {incr i} {
		set node_($i) [$ns_ node]
		$node_($i) random-motion 0

		# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
		set x_pos [expr int($grid_x_dim*rand())] ; #random settings
		set y_pos [expr int($grid_y_dim*rand())] ; #random settings

		while {$x_pos == 0 ||
				$x_pos == $grid_x_dim} {
			set x_pos [expr int($grid_x_dim*rand())]
		}

		while {$y_pos == 0 ||
				$y_pos == $grid_y_dim} {
			set y_pos [expr int($grid_y_dim*rand())]
		}

		$node_($i) set X_ $x_pos;
		$node_($i) set Y_ $y_pos;
		$node_($i) set Z_ 0.0

		puts -nonewline $topo_file "$i x: [$node_($i) set X_] y: [$node_($i) set Y_] \n"
	}

}
puts "============>>> Topology is created ... Line 235";

for {set i 0} {$i < $val(nn)} { incr i } {
	$ns_ initial_node_pos $node_($i) 20
}

#puts "initial_node_pos is done ... Line 241";
# Making node movements random 

if {$gridArrangedOrRandomArranged == 1} {
	#Grid movement
	puts "Grid movement";
	for {set i 0} {$i < $num_node} {incr i} {
		set complimentNodeIndex [expr $num_node - $i - 1];
		set dest_x $positions_of_x($complimentNodeIndex);
		set dest_y $positions_of_y($complimentNodeIndex);

		#puts "-->>For node $i, complimentNodeIndex = $complimentNodeIndex, dest_x = $dest_x, dest_y = $dest_y";
		#puts "For node $i, use destination as positions of $complimentNodeIndex";
		$ns_ at $start_time "$node_($i) setdest $dest_x $dest_y  $node_speed"		
		#puts "$ns_ at $start_time '$node_($i) setdest $dest_x $dest_y  $node_speed' ";
	}
} else {
		puts "Random movement";
		for {set i 0} {$i < [expr $num_node] } {incr i} {
			set dest_x [expr int($grid_x_dim*rand())]
			set dest_y [expr int($grid_y_dim*rand())]

			while {$dest_x == 0 ||
					$dest_x == $grid_x_dim} {
				set dest_x [expr int($grid_x_dim*rand())]
			}

			while {$dest_y == 0 ||
					$dest_y == $grid_y_dim} {
				set dest_y [expr int($grid_y_dim*rand())]
			}
			$ns_ at $start_time "$node_($i) setdest $dest_x $dest_y  $node_speed"

		#puts "$i Destination ---> x: [$node_($i) set X_] y: [$node_($i) set Y_]"
	}
}

puts "node creation complete ";

##################################################Step 5 done############################################



#------------------------------- Step 6. Create flows and associate them with nodes ------------------ #
puts "INSIDE TCL File, num_flow = $num_flow";
for {set i 0} {$i < $num_flow} {incr i} {
	set udp_($i) [new $source_type]
	set null_($i) [new $sink_type]
	$udp_($i) set fid_ $i
	$ns_ color $i Blue
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}
}

#puts "Line 304 done ";

for {set i 0} {$i < $num_flow} {incr i} {
	set source_number [expr int($num_node*rand())]
	set sink_number [expr int($num_node*rand())]
	while {$sink_number==$source_number} {
		set sink_number [expr int($num_node*rand())]
	}
	$ns_ attach-agent $node_($source_number) $udp_($i)
  	$ns_ attach-agent $node_($sink_number) $null_($i)

  	puts "===>>> $i. RANDOM flow:  Src: $source_number Dest: $sink_number"
	
	puts -nonewline $topo_file "RANDOM flow:  Src: $source_number Dest: $sink_number\n"
}

#puts "Line 317 done .";

for {set i 0} {$i < $num_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
	$ns_ at $start_time "$cbr_($i) start"
}

#puts "Line 328 done .";
# Connecting udp_node & null_node
for {set i 0} {$i < $num_flow } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
}
puts "flow creation complete";


##################################################Step 6 done############################################


# ----------------------- Step 7. Set timings of different events ------------------ #

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at [expr $start_time+$time_duration] "$node_($i) reset";
}

$ns_ at [expr $start_time+$time_duration +$extra_time] "finish"
$ns_ at [expr $start_time+$time_duration +$extra_time] "$ns_ nam-end-wireless [$ns_ now]; puts \"NS Exiting...\"; $ns_ halt"


puts "Set timings done ";
########################################## Step 7 done ####################################################


# -------------------------------------- Step 8. finish procedure ------------------------------- #
proc finish {} {
    puts "finishing"
    global ns_ tracefd namtrace topo_file nam_file_name
    $ns_ flush-trace
    close $tracefd
	close $topo_file
    #close $namtrace
    #exec nam $nam_file_name &
    exit 0
}

########################################## Step 8 done ####################################################




# -------------------------------------- Step 9. Run the simulation ------------------------------- #

puts "Starting Simulation..."
$ns_ run

########################################## Step 9 done ####################################################


