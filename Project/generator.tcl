#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
#set val(nn)     10                         ;# number of mobilenodes
set val(rp)     AODV                       ;# routing protocol
set val(x)      2453                       ;# X dimension of topography
set val(y)      1939                       ;# Y dimension of topography
set val(stop)   200.0                      ;# time of simulation end

puts "CHOOSE From the given CASE"
puts "1. 10Nodes" 
puts "2. 30Nodes" 
puts "3. 60Nodes"
set case [gets stdin];
if {$case == 1} {
    set root "10Nodes" ;
    file mkdir $root  ;
} elseif {$case == 2} {
    set root 30Nodes ;
    file mkdir $root  ;
} elseif {$case == 3} {
    set root 60Nodes ;
    file mkdir $root  ;
} else {
    puts "Wrong Choice"
    exit 2
}
puts "Enter the TCP Agent in mobile networking";
puts "1. TCP" 
puts "2. TCPTahoe" 
puts "3. TCPReno"
puts "4. TCPNewReno"
puts "5. TCPVegas"
set tcpAgent [gets stdin];
#Setup a TCP connection
if {$tcpAgent == 1} {    
    set filename "TCP_"
} elseif {$tcpAgent == 2} {
    set filename "TCPTahoe_"
} elseif {$tcpAgent == 3} {
    set filename "TCPReno_"
} elseif {$tcpAgent == 4} {
    set filename "TCPNewReno_"
} elseif {$tcpAgent ==5} {    
    set filename "TCPVegas_"
} else {
    puts "Wrong Choice"
    exit 2
}
puts "Enter the Routing Agents in mobile networking"
puts "1. AODV" 
puts "2. DSDV" 
puts "3. DSR"
set routingProtocol [gets stdin];
if {$routingProtocol == 1} {
    set path ${root}/temp/AODV ;
    file mkdir $path ;
    set val(ifq)    Queue/DropTail/PriQueue;
    set val(rp)     AODV                     ;# routing protocol
    set filename "${filename}AODV";
    set tracefile [open "${path}/${filename}.tr" w];
    set namfile [open "${path}/${filename}.nam" w]; 
} elseif {$routingProtocol == 2} {
    set path ${root}/temp/DSDV ;
    file mkdir $path ;    
    set val(ifq)    Queue/DropTail/PriQueue;
    set val(rp)     DSDV                     ;# routing protocol
    set filename "${filename}DSDV";
    set tracefile [open "${path}/${filename}.tr" w];
    set namfile [open "${path}/${filename}.nam" w];   
} elseif {$routingProtocol == 3} {
    set path ${root}/temp/DSR ;
    file mkdir $path ;
    set val(ifq)    CMUPriQueue;
    set val(rp)     DSR                      ;# routing protocol
    set filename "${filename}DSR";
    set tracefile [open "${path}/${filename}.tr" w];
    set namfile [open "${path}/${filename}.nam" w];  
}  else {
    puts "Wrong choice"
    exit 2
}
if {$case == 1} {  
    set starting "_0_"
    set ending "_9_"
    source source1_10Nodes.tcl
} elseif {$case == 2} {
    set starting "_0_"
    set ending "_29_"
    source source1_30Nodes.tcl
} elseif {$case == 3} {
    set starting "_0_"
    set ending "_59_"
    source source1_60Nodes.tcl
} else {
    puts "Wrong Choice"
    exit 2
}
#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile filename path starting ending
    $ns flush-trace
    close $tracefile
    close $namfile
    file mkdir $path/cwnd
    file mkdir $path/inst/TP
    file mkdir $path/inst/E2ED
    exec nam "${path}/${filename}.nam" &
    exec gawk -v startNode=${starting} -v endNode=${ending} -f inst_ThroughPut.awk "${path}/${filename}.tr" > "${path}/inst/TP/${filename}_inst_TP.tr" 
    exec gawk -v startNode=${starting} -v endNode=${ending} -f inst_E_2_E_Delay.awk "${path}/${filename}.tr"  > "${path}/inst/E2ED/${filename}_inst_E2ED.tr" 
    exec gawk -v startNode=${starting} -v endNode=${ending} -f avg_ThroughPut.awk "${path}/${filename}.tr" &
    exec gawk -v startNode=${starting} -v endNode=${ending} -f PDR_Avg_E_2_E.awk "${path}/${filename}.tr" &
    exec gawk -f congestion_window.awk "${path}/${filename}.tr" > "${path}/cwnd/${filename}_cwnd.tr"
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
