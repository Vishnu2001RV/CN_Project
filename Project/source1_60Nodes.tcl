#setdest -v 2 -n 60 -s 2 -m 10 -M 20 -t 100 -P 1 -p 10 -x 1000 -y 500 > scenario

#===================================
#        Initialization        
#===================================

set val(nn)     60                        ;# number of mobilenodes
set val(x)      1000                     ;# X dimension of topography
set val(y)      500                     ;# Y dimension of topography

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
set god_ [create-god $val(nn)]
for { set i 0 } { $i < $val(nn) } { incr i } { 
   set n$i [$ns node] 
 }

source mobility60Nodes.attach

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

$ns attach-agent $n0 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n59 $sink1
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