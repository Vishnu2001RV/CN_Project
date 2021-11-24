BEGIN {
    seqno_tcp = 0;
    droppedPackets_tcp = 0;
    receivedPackets_tcp = 0;
    n_to_n_delay_tcp = 0
    count = 0;
}
{
	# Trace line format: normal
	if ($2 != "-t") {
		event = $1
		time = $2
		node_id = $3
		flow_id = $8
		#pkt_id = $12
		pkt_size = $8
		#previous $5
		flow_t = $7
		#agt or other ifq for drop etc
		level = $4 
	}
	# Trace line format: new
	if ($2 == "-t") {
		event = $1
		time = $3
		node_id = $5
		flow_id = $39
		#pkt_id = $41
		pkt_size = $37
		flow_t = $45
		level = $19
	}
   #packet delivery ratio
   if((level == "AGT" || level == "IFQ") && (event == "+" || event == "s")&&(node_id==startNode))
   {
      if(flow_t == "tcp")
      {
        seqno_tcp++;
      }
   }
   
   if((level == "AGT" || level == "IFQ") && event == "r"&&(node_id==endNode)) {
      if(flow_t == "tcp"||flow_t == "ack")
      {
        receivedPackets_tcp++;
      }
   
   } 
   else if (event == "D"){
      if(flow_t == "tcp"||flow_t == "ack")
      {
        droppedPackets_tcp++;
      }
   
   }
   
   #end-to-end delay
   if((level == "AGT" || level == "IFQ") && (event == "+" || event == "s")&&(node_id==startNode)) {
   
      if(flow_t == "tcp"||flow_t == "ack")
      {
        start_time_tcp[seqno_tcp] = $2;
      }
   
   } 
   else if((level == "AGT" || level == "IFQ") && event == "r"&&(node_id==endNode)) {  
       if(flow_t == "tcp"||flow_t == "ack")
         {
            end_time_tcp[seqno_tcp] = $2;
         }  
   } 
   else if(event == "D") {
      if(flow_t == "tcp"||flow_t == "ack")
         {
           end_time_tcp[seqno_tcp] = 0;
         }
   }
}

END { 
   for(i=0; i <= seqno_tcp; i++) {
      if(end_time_tcp[i] > 0) {
          delay_tcp[i] = end_time_tcp[i] - start_time_tcp[i];
          if(delay_tcp[i] > 0) {
              n_to_n_delay_tcp = n_to_n_delay_tcp + delay_tcp[i];
          }
      }
  }
   packet_ratio_tcp = 0
   if(seqno_tcp>0){
       packet_ratio_tcp = receivedPackets_tcp/(seqno_tcp)*100
       n_to_n_delay_tcp = n_to_n_delay_tcp /(seqno_tcp);
   }

   print "\n";
   print "PacketDelivaryRatio And End to End Delay"
   print "TCP "
   print "     GeneratedPackets = " seqno_tcp;
   print "     ReceivedPackets = " receivedPackets_tcp;
   print "     Packet Delivery Ratio = " packet_ratio_tcp "%";
   print "     Total Dropped Packets = " seqno_tcp-receivedPackets_tcp;#droppedPackets_tcp;
   print "     Average End-to-End Delay = " n_to_n_delay_tcp * 1000 " ms";
   print "\n";
}
