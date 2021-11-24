BEGIN {
	recvdSize_tcp = 0
	startTime_tcp = 1e6
	stopTime_tcp =0
	recvdNum_tcp = 0
}
{
	# Trace line format: normal
	if ($2 != "-t") {
		event = $1
		time = $2
		node_id = $3
		flow_id = $8
		pkt_id = $12
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
		pkt_id = $41
		pkt_size = $37
		flow_t = $45
		level = $19
	}
	if ((level == "AGT" || level == "IFQ") && (event == "+" || event == "s")&&(node_id==startNode)) {
	
	        if(flow_t == "tcp")
	            if (time < startTime_tcp)
	                 startTime_tcp = time	            
	                    
	}
	if ((level == "AGT" || level == "IFQ") && event == "r"&&(node_id==endNode)) {
	
	        if(flow_t == "tcp"||flow_t == "ack")
	           {
		            recvdSize_tcp += pkt_size
		            recvdNum_tcp += 1
	                if (time > stopTime_tcp)
	                      stopTime_tcp = time
	                 
	           }	 
	}
}
END {
	
	if (recvdNum_tcp == 0) {
		printf("Warning: no packets were received, simulation may be too short for tcp \n")
	}
    printf("\nAverage ThroughPut")
	printf("\nTCP \n")
	printf(" %15s:  %f\n", "startTime", startTime_tcp)
	printf(" %15s:  %f\n", "stopTime", stopTime_tcp)
	printf(" %15s:  %g\n", "receivedPkts", recvdNum_tcp)	
    printf("     Average ThroughPut %15s:  %g\n", "avgTput[kbps]", (recvdSize_tcp/(stopTime_tcp-startTime_tcp))*(8/1000))	

}
