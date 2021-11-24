BEGIN {
    recv_tcp = 0
	currTime = prevTime = 0
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
	# Init prevTime to the first packet recv time
	if(prevTime == 0)
		prevTime = time

	# Calculate total received packets' size
	if ((level == "AGT" || level == "IFQ") && event == "r"&&(node_id==endNode)) {
	    if ((flow_t == "tcp")||(flow_t == "ack"))
	    {
	    #tcp
	    recv_tcp += pkt_size
	    
	    }
	    currTime += (time - prevTime)  
	    if (currTime >= tic) {
            printf("%f %f\n",time,(recv_tcp/currTime)*(8/1000))         
	        recv_tcp=0
	        currTime = 0    
		}
		prevTime = time
	}
}
END {
	printf("\n\n")
}
