#=================================Roll 5(5) and 22(6)=====================================
#This is 802.11 static wireless (with TCP Agent)


#------------------------------ Step 1. Set values of parameters ------------------------------ 

	#a) Network size
	set x_dim [lindex $argv 9]
	set y_dim [lindex $argv 10]

	#b) Number of nodes
	set num_row [lindex $argv 0] ;#number of row
	set num_col [lindex $argv 1] ;#number of column


	#c) Flow setting
	set num_parallel_flow [lindex $argv 2]
	set num_cross_flow [lindex $argv 3]
	set num_random_flow 0

	#Number of packets per second inversely proportional to constant bit rate interval
	set cbr_size 1000
	set cbr_rate 11.0Mb
	set cbr_interval [lindex $argv 4];# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second

	set start_time [lindex $argv 12] ;#100
	set time_duration [lindex $argv 13] ;#50
	
	set parallel_start_gap 0.0
	set cross_start_gap 0.0

	set grid [lindex $argv 11];	# 1 for grid topology, 0 for random topology
	set extra_time 10 ;#10

	set coefficientOfTX [lindex $argv 5];

	#d) Setting energy parameters

	set val(energymodel_11)    			EnergyModel     ;
	set val(initialenergy_11)  			1000            ;# Initial energy in Joules
	set val(idlepower_11) 				900e-3			;#Stargate (802.11b) 
	set val(rxpower_11) 				925e-3			;#Stargate (802.11b)
	set val(txpower_11) 				1425e-3			;#Stargate (802.11b)
	set val(sleeppower_11) 				300e-3			;#Stargate (802.11b)
	set val(transitionpower_11) 		200e-3			;#Stargate (802.11b)	??????????????????????????????/
	set val(transitiontime_11) 			3				;#Stargate (802.11b)

	set nowValue [Phy/WirelessPhy set Pt_]              ;#   0.001
	puts "INSIDE TCL FILE, INITIAL VALUE of Pt_ = $nowValue of Pt_"
	set newValue_Pt [expr $coefficientOfTX * $coefficientOfTX * $nowValue];	#To change coverage area, multiply with coefficient^2 X Pt_
	Phy/WirelessPhy set Pt_ 			$newValue_Pt;	

	set nowValue [Phy/WirelessPhy set Pt_]              ;#   0.001
	puts "INSIDE TCL FILE, AFTER CHANGING nowValue of Pt_ = $nowValue of Pt_"
	

	#e) Protocols and models for different layers

	set tcp_src Agent/TCP ;# Agent/TCP or Agent/TCP/Reno or Agent/TCP/Newreno or Agent/TCP/FullTcp/Sack or Agent/TCP/Vegas
	set tcp_sink Agent/TCPSink ;# Agent/TCPSink or Agent/TCPSink/Sack1


	set doWeUseModifiedCongestion [lindex $argv 15]; #If this is 1.. then use the next argument for congestion control mechanism modified.
	
	if {$doWeUseModifiedCongestion == 1} {
		#Yes we do use modified method ..
		set newCase_forModification [lindex $argv 16];
		$tcp_src set windowOption_ $newCase_forModification; #For Congestion Control Case 9 or Case 10 (MODIFIED)
	}


	set val(chan)						Channel/WirelessChannel 	;# channel type
	set val(prop) 						Propagation/TwoRayGround 	;# radio-propagation model
	#set val(prop) Propagation/FreeSpace ;# radio-propagation model
	set val(netif) 						Phy/WirelessPhy 			;# network interface type
	set val(mac) 						Mac/802_11 					;# MAC type
	set val(ifq) 						Queue/DropTail/PriQueue 	;# interface queue type
	set val(ll) 						LL 							;# link layer type
	set val(ant) 						Antenna/OmniAntenna 		;# antenna model
	set val(ifqlen) 					50 							;# max packet in ifq
	set val(rp) 						AODV 						;# routing protocol eg. DSDV / AODV 


	

######################################## STEP 1 done ###############################################

# --------------------------------------------- Step 2. Initialize ns ---------------------------------------------
set ns_ [new Simulator]

######################################## STEP 2 done ###############################################


#-------------------- Step 3. Open required files (eg. trace file , nam file)----------------


#=============== Taking names of required files from bash ================
#set nm tcp_wireless.nam
#set tr trace_tcp_wireless.tr
#set topo_file topo_tcp_wireless.txt

set nm [lindex $argv 6]
set tr [lindex $argv 7]
set topo_file [lindex $argv 8]


set tracefd [open $tr w]
$ns_ trace-all $tracefd

#$ns_ use-newtrace ;# use the new wireless trace file format

set namtrace [open $nm w]
$ns_ namtrace-all-wireless $namtrace $x_dim $y_dim

#set topofilename "topo_ex3.txt"
set topofile [open $topo_file "w"]

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $x_dim $y_dim
#$topo load_flatgrid 1000 1000

create-god [expr $num_row*$num_col]

######################################## STEP 3 done ###############################################

#------------------------------- Step 4. Set node configuration ----------------------------------

$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace ON -routerTrace OFF\
     -macTrace ON \
     -movementTrace OFF \
			 -energyModel $val(energymodel_11) \
			 -idlePower $val(idlepower_11) \
			 -rxPower $val(rxpower_11) \
			 -txPower $val(txpower_11) \
          		 -sleepPower $val(sleeppower_11) \
          		 -transitionPower $val(transitionpower_11) \
			 -transitionTime $val(transitiontime_11) \
			 -initialEnergy $val(initialenergy_11)


#          		 -transitionTime 0.005 \
 
#==================--------------Step 5. Create nodes with positioning--------------===========================
#Start creating nodes .... 
puts "start node creation"
for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0
	#Above code helps for static
}


#FULL CHNG
set x_start [expr $x_dim/($num_col*2)];
set y_start [expr $y_dim/($num_row*2)];
set i 0;
while {$i < $num_row } {
#in same column
    for {set j 0} {$j < $num_col } {incr j} {
#in same row
	set m [expr $i*$num_col+$j];
#	$node_($m) set X_ [expr $i*240];
#	$node_($m) set Y_ [expr $k*240+20.0];
#CHNG
	if {$grid == 1} {
		set x_pos [expr $x_start+$j*($x_dim/$num_col)];#grid settings
		set y_pos [expr $y_start+$i*($y_dim/$num_row)];#grid settings
	} else {
		set x_pos [expr int($x_dim*rand())] ;#random settings
		set y_pos [expr int($y_dim*rand())] ;#random settings
	}
	$node_($m) set X_ $x_pos;
	$node_($m) set Y_ $y_pos;
	$node_($m) set Z_ 0.0
#	puts "$m"
	puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
    }
    incr i;
}; 

if {$grid == 1} {
	puts "GRID topology"
} else {
	puts "RANDOM topology"
}
puts "node creation complete"
#CHNG
#--------------------------------------------------THIS LINE IS CHANGED------------------------------
#if {$num_parallel_flow > $num_row} {
#	set num_parallel_flow $num_row
#}

#CHNG
#if {$num_cross_flow > $num_col} {
#	set num_cross_flow $num_col
#}


#==================--------------Step 6. Create flows and associate them with nodes--------------===========================

#CHNG
for {set i 0} {$i < [expr $num_parallel_flow + $num_cross_flow + $num_random_flow]} {incr i} {
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]

	set udp_($i) [new $tcp_src]
	$udp_($i) set class_ $i
	set null_($i) [new $tcp_sink]
	$udp_($i) set fid_ $i
	
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}
} 

################################################PARALLEL FLOW

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set udp_node $i
	#set null_node [expr $i+(($num_col)*($num_row-1))];#CHNG
	set null_node [expr ($num_col*$num_row)-$i-1];
	$ns_ attach-agent $node_($udp_node) $udp_($i)
  	$ns_ attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "PARALLEL: Src: $udp_node Dest: $null_node\n"
} 

#  $ns_ attach-agent $node_(0) $udp_(0)
#  $ns_ attach-agent $node_(6) $null_(0)

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
}
#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
} 

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns_ at [expr $start_time+$i*$parallel_start_gap] "$cbr_($i) start"
}
####################################CROSS FLOW
#CHNG
set k $num_parallel_flow 
#for {set i 1} {$i < [expr $num_col-1] } {incr i} {
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	set udp_node [expr $i*$num_col];#CHNG
	set null_node [expr ($i+1)*$num_col-1];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($k)
  	$ns_ attach-agent $node_($null_node) $null_($k)
	puts -nonewline $topofile "CROSS: Src: $udp_node Dest: $null_node\n"
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns_ connect $udp_($k) $null_($k)
	incr k
}
#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	set cbr_($k) [new Application/Traffic/CBR]
	$cbr_($k) set packetSize_ $cbr_size
	$cbr_($k) set rate_ $cbr_rate
	$cbr_($k) set interval_ $cbr_interval
	$cbr_($k) attach-agent $udp_($k)
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns_ at [expr $start_time+$i*$cross_start_gap] "$cbr_($k) start"
	incr k
}
#######################################################################RANDOM FLOW
set r $k
set rt $r
set num_node [expr $num_row*$num_col]
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	set udp_node [expr int($num_node*rand())] ;# src node
	set null_node $udp_node
	while {$null_node==$udp_node} {
		set null_node [expr int($num_node*rand())] ;# dest node
	}
	$ns_ attach-agent $node_($udp_node) $udp_($rt)
  	$ns_ attach-agent $node_($null_node) $null_($rt)
	puts -nonewline $topofile "RANDOM:  Src: $udp_node Dest: $null_node\n"
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	$ns_ connect $udp_($rt) $null_($rt)
	incr rt
}
set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval
	$cbr_($rt) attach-agent $udp_($rt)
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	$ns_ at [expr $start_time] "$cbr_($rt) start"
	incr rt
}

puts "flow creation complete"
##########################################################################END OF FLOW GENERATION



##############################PRINTING THINGS FOR DEBUGGING####################################
puts "=======================PRINTING FOR DEBUGGING============================="
puts "start_time = $start_time"
puts "time_duration = $time_duration"
puts "num_row = $num_row , num_col = $num_col"
puts "num_parallel_flow = $num_parallel_flow, num_cross_flow = $num_cross_flow , num_random_flow = $num_random_flow"
puts "===================================================="

##############################PRINTING THINGS FOR DEBUGGING DONE####################################

#==================--------------Step 7. Set timings of different events--------------===========================


# Tell nodes when the simulation ends
#
for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
    $ns_ at [expr $start_time+$time_duration] "$node_($i) reset";
}
$ns_ at [expr $start_time+$time_duration +$extra_time] "finish"
#$ns_ at [expr $start_time+$time_duration +20] "puts \"NS Exiting...\"; $ns_ halt"
$ns_ at [expr $start_time+$time_duration +$extra_time] "$ns_ nam-end-wireless [$ns_ now]; puts \"NS Exiting...\"; $ns_ halt"

$ns_ at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns_ at [expr $start_time+$time_duration] "puts \"end of simulation duration\""




#===========------Step 8. Write tasks to do after finishing simulations in procedure called "finish"------==========

proc finish {} {
	puts "finishing"
	global ns_ tracefd namtrace topofile nm
	#global ns_ topofile
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	close $topofile
#        exec nam $nm &
        exit 0
}

#set opt(mobility) "position.txt"
#source $opt(mobility)
#set opt(traff) "traffic.txt"
#source $opt(traff)
#==================--------------Step 9. Run the simulation --------------===========================
set sizeNode [lindex $argv 14]
for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns_ initial_node_pos $node_($i) $sizeNode
	#	$ns_ initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns_ run 
#$ns_ nam-end-wireless [$ns_ now]

