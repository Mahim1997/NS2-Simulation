# Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# wireless2.tcl
# simulation of a wired-cum-wireless scenario consisting of 2 wired nodes
# connected to a wireless domain through a base-station node.
# ======================================================================
# Define options
# ======================================================================


set num_wired_nodes      4
set num_bs_nodes         1
set num_wireless_nodes   3



    set opt(chan)           Channel/WirelessChannel    ;# channel type
    set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
    set opt(netif)          Phy/WirelessPhy            ;# network interface type
    set opt(mac)            Mac/802_11                 ;# MAC type
    set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
    set opt(ll)             LL                         ;# link layer type
    set opt(ant)            Antenna/OmniAntenna        ;# antenna model
    set opt(ifqlen)         50                         ;# max packet in ifq
    set opt(nn)             $num_wireless_nodes        ;# number of mobilenodes
    set opt(adhocRouting)   AODV                       ;# routing protocol
#DSDV not used

##ENERGY MODELS
    set val(energymodel_11)             EnergyModel     ;
    set val(initialenergy_11)           1000            ;# Initial energy in Joules
    set val(idlepower_11)               900e-3          ;#Stargate (802.11b) 
    set val(rxpower_11)                 925e-3          ;#Stargate (802.11b)
    set val(txpower_11)                 1425e-3         ;#Stargate (802.11b)
    set val(sleeppower_11)              300e-3          ;#Stargate (802.11b)
    set val(transitionpower_11)         200e-3          ;#Stargate (802.11b)    ??????????????????????????????/
    set val(transitiontime_11)          3               ;#Stargate (802.11b)


set opt(cp)             ""                         ;# connection pattern file
set opt(sc)     "../mobility/scene/scen-3-test"    ;# node movement file. 

set opt(x)      100                            ;# x coordinate of topology
set opt(y)      100                            ;# y coordinate of topology
set opt(seed)   0.0                            ;# seed for random number gen.
set opt(stop)   250                            ;# time to stop simulation

set opt(ftp1-start)      1
set opt(ftp2-start)      2
set opt(ftp3-start)      3
set opt(ftp4-start)      4



# ============================================================================
# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
    puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
    puts "Seeding Random number generator with $opt(seed)\n"
    ns-random $opt(seed)
}

# create simulator instance
set ns_   [new Simulator]

# set up for hierarchical routing
$ns_ node-config -addressType hierarchical
AddrParams set domain_num_ 2           ;# number of domains
lappend cluster_num 4 1                ;# number of clusters in each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 1 1 4              ;# number of nodes in each cluster 
AddrParams set nodes_num_ $eilastlevel ;# of each domain

set tracefd  [open Wireless2/wireless2-out.tr w]
set namtrace [open Wireless2/wireless2-out.nam w]
set qsize1 [open Wireless2/qsize1.tr w]
set qsize2 [open Wireless2/qsize2.tr w]
set qsize3 [open Wireless2/qsize3.tr w]
set qsize4 [open Wireless2/qsize4.tr w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Create topography object
set topo   [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# create God
create-god [expr $opt(nn) + $num_bs_nodes]

#create wired nodes
set temp {0.0.0 0.1.0 0.2.0 0.3.0 0.4.0}        ;# hierarchical addresses for wired domain
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp $i]] 
}

# configure for base-station node
$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
         -topoInstance $topo \
                 -wiredRouting ON \
         -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF 

#create base-station node
set temp {1.0.0 1.0.1 1.0.2 1.0.3}   ;# hier address to be used for wireless
                                     ;# domain
set BS(0) [$ns_ node [lindex $temp 0]]
$BS(0) random-motion 0               ;# disable random motion

#provide some co-ord (fixed) to base station node
$BS(0) set X_ 40.0
$BS(0) set Y_ 50.0
$BS(0) set Z_ 0.0
# create mobilenodes in the same domain as BS(0)  
# note the position and movement of mobilenodes is as defined
# in $opt(sc)

#configure for wireless nodes energy params
$ns_ node-config -energyModel $val(energymodel_11) \
             -idlePower $val(idlepower_11) \
             -rxPower $val(rxpower_11) \
             -txPower $val(txpower_11) \
                 -sleepPower $val(sleeppower_11) \
                 -transitionPower $val(transitionpower_11) \
             -transitionTime $val(transitiontime_11) \
             -initialEnergy $val(initialenergy_11)
$ns_ node-config -wiredRouting OFF




  for {set j 0} {$j < $opt(nn)} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp \
        [expr $j+1]] ]
    $node_($j) base-station [AddrParams addr2id \
        [$BS(0) node-addr]]
}

############# COlor the nodes .....

#Color wired nodes as green
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    $W($i) color blue ;
}
#Color base station as red
for {set i 0} {$i < $num_bs_nodes} {incr i} {
    $BS($i) color red ;
}

#Color wireless nodes as blue
for {set i 0} {$i < $num_wireless_nodes} {incr i} {
    #$node_($i) color blue ;
    $node_($i) color "#0000FF";
}



############# COlor the nodes done .....

#create links between wired and BS nodes

$ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail
$ns_ duplex-link $W(0) $W(2) 5Mb 2ms DropTail
$ns_ duplex-link $W(2) $W(1) 5Mb 2ms DropTail
#$ns_ duplex-link $W(3) $W(1) 5Mb 2ms DropTail
#$ns_ duplex-link $W(3) $W(4) 5Mb 2ms DropTail
$ns_ duplex-link $W(1) $W(3) 5Mb 2ms DropTail
$ns_ duplex-link $W(3) $BS(0) 5Mb 2ms DropTail

$ns_ duplex-link-op $W(0) $W(1) orient right-down
$ns_ duplex-link-op $W(0) $W(2) orient right
$ns_ duplex-link-op $W(2) $W(1) orient left-down
#$ns_ duplex-link-op $W(3) $W(4) orient right-down
$ns_ duplex-link-op $W(1) $W(3) orient down
$ns_ duplex-link-op $W(3) $BS(0) orient down

# setup TCP connections
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $W(0) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at $opt(ftp1-start) "$ftp1 start"

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $W(1) $tcp2
$ns_ attach-agent $node_(2) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns_ at $opt(ftp2-start) "$ftp2 start"

set tcp3 [new Agent/TCP]
$tcp3 set class_ 2
set sink3 [new Agent/TCPSink]
$ns_ attach-agent $W(2) $tcp3
$ns_ attach-agent $W(3) $sink3
$ns_ connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ns_ at $opt(ftp3-start) "$ftp3 start"

set tcp4 [new Agent/TCP]
$tcp4 set class_ 2
set sink4 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp4
$ns_ attach-agent $W(3) $sink4
$ns_ connect $tcp4 $sink4
set ftp4 [new Application/FTP]
$ftp4 attach-agent $tcp4
$ns_ at $opt(ftp4-start) "$ftp4 start"
# source connection-pattern and node-movement scripts
set qf_size1 [open Wireless2/queue1.size w]
set qmon_size1 [$ns_ monitor-queue $W(1) $W(3) $qf_size1 0.05]
set qf_size2 [open Wireless2/queue2.size w]
set qmon_size2 [$ns_ monitor-queue $W(0) $W(2) $qf_size2 0.05]
set qf_size3 [open Wireless2/queue3.size w]
set qmon_size3 [$ns_ monitor-queue $W(0) $W(1) $qf_size3 0.05]
set qf_size4 [open Wireless2/queue4.size w]
set qmon_size4 [$ns_ monitor-queue $W(3) $BS(0) $qf_size4 0.05]
if { $opt(cp) == "" } {
    puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
    puts "Loading connection pattern..."
    source $opt(cp)
}
#if { $opt(sc) == "" } {
#   puts "*** NOTE: no scenario file specified."
#        set opt(sc) "none"
#} else {
#   puts "Loading scenario file..."
#   source $opt(sc)
#   puts "Load complete..."
#}

# Define initial node position in nam
#    $node_(0) set X_ 40.0
#    $node_(0) set Y_ 80.0
#    $node_(0) set Z_ 0.0
#    $node_(1) set X_ 80.0
#    $node_(1) set Y_ 80.0
#    $node_(1) set Z_ 0.0
#    $node_(2) set X_ 40.0
#    $node_(2) set Y_ 50.0
#    $node_(2) set Z_ 0.0

#Another position..
#$BS(0) set X_ 40.0
#$BS(0) set Y_ 50.0
#$BS(0) set Z_ 0.0
    $node_(0) set X_ -20.0
    $node_(0) set Y_ 10.0
    $node_(0) set Z_ 0.0
    $node_(1) set X_ 20.0
    $node_(1) set Y_ 10.0
    $node_(1) set Z_ 0.0
    $node_(2) set X_ 15.0
    $node_(2) set Y_ -5.0
    $node_(2) set Z_ 0.0



for {set i 0} {$i < $opt(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your
    # scenario
    # The function must be called after mobility model is defined
    $ns_ initial_node_pos $node_($i) 7;
}     

# Tell all nodes when the simulation ends
for {set i } {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
}
$ns_ at 0.0 "record"
$ns_ at $opt(stop).0 "$BS(0) reset";

$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0001 "stop"
proc stop {} {
    global ns_ tracefd namtrace qsize1 qsize2 qsize3 qsize4
    $ns_ flush-trace
    close $tracefd
    close $namtrace
    close $qsize1
    close $qsize2
    close $qsize3
    close $qsize4
    exec nam Wireless2/wireless2-out.nam &
    #exec xgraph qsize1.tr -geometry 800x400 &
    #exec xgraph qsize2.tr -geometry 800x400 &
    #exec xgraph qsize3.tr -geometry 800x400 &
    #exec xgraph qsize4.tr -geometry 800x400 &
}
proc record {} {
    global ns_ qmon_size1 qmon_size2 qmon_size3 qmon_size4  qsize1 qsize2 qsize3 qsize4
    set ns_ [Simulator instance]
    set time 0.05
    set now [$ns_ now]

    $qmon_size1 instvar size_ pkts_ barrivals_ bdepartures_ parrivals_ pdepartures_ bdrops_ pdrops_
    $qmon_size2 instvar size_ pkts_ barrivals_ bdepartures_ parrivals_ pdepartures_ bdrops_ pdrops_ 
    puts $qsize1 "$now [$qmon_size1 set size_]"
    puts $qsize2 "$now [$qmon_size2 set size_]"
    puts $qsize3 "$now [$qmon_size3 set size_]"
    puts $qsize4 "$now [$qmon_size4 set size_]"
    #puts $qbw "$now [expr ($bdepartures_ - $old_departure)*8/$time]" 
    $ns_ at [expr $now+$time] "record"
}
# informative headers for CMUTracefile
puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp \
    $opt(adhocRouting)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."
$ns_ run
