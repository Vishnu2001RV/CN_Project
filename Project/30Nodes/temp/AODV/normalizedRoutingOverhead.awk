BEGIN{
recvs = 0;
routing_packets = 0;
}

{
if (( $1 == "r") &&  ( $7 == "tcp" ) && ( $4=="AGT" ))  recvs++;
if (($1 == "s" || $1 == "f") && $4 == "RTR" && ( $7 =="AODV" || $7 =="message" || $7 =="DSR") ) routing_packets++;
}

END{
printf("NRL = %.3f", routing_packets/recvs);
}
