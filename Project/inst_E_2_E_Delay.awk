BEGIN {
seqno_tcp = 0;
mini_n_to_n_delay_tcp = 0
tic = 25 #0.1
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
    if(prevTime == 0)
	prevTime = time

	#end-to-end delay
    if((level == "AGT" || level == "IFQ") && (event == "+" || event == "s")&&(node_id==startNode)) {
              if(flow_t == "tcp"||flow_t == "ack")
              {
                seqno_tcp++;
                start_time_tcp[seqno_tcp] = $2;         
              }
           } 
     if((level == "AGT" || level == "IFQ") && event == "r"&&(node_id==endNode)) {
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

    if(flow_t == "tcp"||flow_t == "ack") {
          delay_tcp[seqno_tcp] = end_time_tcp[seqno_tcp] - start_time_tcp[seqno_tcp]; 
          if(delay_tcp[seqno_tcp] > 0) 
               mini_n_to_n_delay_tcp = mini_n_to_n_delay_tcp + delay_tcp[seqno_tcp]; 
          
      }
    currTime += (time - prevTime)  
    if (currTime>= tic) {
       tcp_delay = 0.0
       if(seqno_tcp!=0)
           tcp_delay = mini_n_to_n_delay_tcp /(seqno_tcp) * 1000       
       printf("%f %f\n",time,tcp_delay)
       currTime = 0  
       mini_n_to_n_delay_tcp = 0
       seqno_tcp = 0
    }
    prevTime = time
}



