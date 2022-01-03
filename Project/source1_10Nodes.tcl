#===================================
#        Initialization        
#===================================
set val(nn)     10                         ;# number of mobilenodes
set val(x)      2453                       ;# X dimension of topography
set val(y)      1939                       ;# Y dimension of topography
#Create a ns simulator
set ns [new Simulator]
#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)
#Open the NS trace file
$ns trace-all $tracefile
#Open the NAM trace file
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel
#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
#Create 10 nodes
set n0 [$ns node]
$n0 set X_ 1202
$n0 set Y_ 1698
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 1372
$n1 set Y_ 1538
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 1361
$n2 set Y_ 1839
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20
set n3 [$ns node]
$n3 set X_ 1549
$n3 set Y_ 1911
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20
set n4 [$ns node]
$n4 set X_ 1636
$n4 set Y_ 1644
$n4 set Z_ 0.0
$ns initial_node_pos $n4 20
set n5 [$ns node]
$n5 set X_ 1733
$n5 set Y_ 1808
$n5 set Z_ 0.0
$ns initial_node_pos $n5 20
set n6 [$ns node]
$n6 set X_ 1522
$n6 set Y_ 1551
$n6 set Z_ 0.0
$ns initial_node_pos $n6 20
set n7 [$ns node]
$n7 set X_ 1736
$n7 set Y_ 1598
$n7 set Z_ 0.0
$ns initial_node_pos $n7 20
set n8 [$ns node]
$n8 set X_ 1829
$n8 set Y_ 1761
$n8 set Z_ 0.0
$ns initial_node_pos $n8 20
set n9 [$ns node]
$n9 set X_ 1836
$n9 set Y_ 1892
$n9 set Z_ 0.0
$ns initial_node_pos $n9 20
#===================================
#        Generate movement          
#===================================
$ns at 1.0 " $n2 setdest 1424 1740 10 " 
$ns at 14 " $n2 setdest 1361 1839 10 " 
$ns at 28 " $n2 setdest 1424 1740 10 " 
$ns at 42 " $n2 setdest 1361 1839 10 " 
$ns at 56 " $n2 setdest 1424 1740 10 " 
$ns at 60 " $n2 setdest 1361 1839 10 " 
$ns at 74 " $n2 setdest 1424 1740 10 " 
$ns at 88 " $n2 setdest 1361 1839 10 " 
$ns at 74 " $n4 setdest 1522 1698 10 " 
$ns at 1.0 " $n5 setdest 1625 1789 10 " 
$ns at 14 " $n5 setdest 1733 1808 10 " 
$ns at 28 " $n5 setdest 1625 1789 10 " 
$ns at 42 " $n5 setdest 1733 1808 10 "
#===================================
#        Agents Definition        
#===================================
#Setup a TCP connection
if {$tcpAgent == 1} {
    set tcp0 [new Agent/TCP]
} elseif {$tcpAgent == 2} {
    set tcp0 [new Agent/TCP/FullTcp/Tahoe]
} elseif {$tcpAgent == 3} {
    set tcp0 [new Agent/TCP/Reno]
} elseif {$tcpAgent == 4} {
    set tcp0 [new Agent/TCP/Newreno]
} elseif {$tcpAgent ==5} {
    set tcp0 [new Agent/TCP/Vegas]
}
$tcp0 attach $tracefile
$tcp0 tracevar cwnd_
$tcp0 tracevar ssthresh_
$tcp0 tracevar ack_
$tcp0 tracevar maxseq_
$ns attach-agent $n0 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n9 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 2500
#===================================
#        Applications Definition        
#===================================
#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"
$ns at 200.0 "$ftp0 stop"
