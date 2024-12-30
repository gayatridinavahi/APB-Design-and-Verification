class apb_iMonitor ;

bit [31:0] no_of_pkts_recvd;
apb_trans   pkt;
virtual apb_if.Mon vif;
mailbox #(apb_trans) mbx;//will be connected to input of scoreboard


function new (input mailbox #(apb_trans) mbx_in,
              input virtual apb_if.Mon vif_in
	         );
this.mbx = mbx_in;
this.vif = vif_in;
endfunction

task run() ;
bit [15:0] addr;
$display("[apb_iMonitor] run started at time=%0t ",$time); 
forever begin 
    do //Wait for SETUP phase
    @(vif.cbm);
    while(vif.cbm.PSEL === 0 || vif.cbm.PSEL === 'x );  
    if(	vif.cbm.PWRITE ===1'b0) continue;//skip incase of READ operation
    @(vif.cbm);//Wait for Access phase
    if(vif.cbm.PENABLE !==1) begin
	$display("[Error] APB Protocol Violation :: Setup Phase not followed by Access Phase");
    end
    pkt=new;
	
    while (!vif.cbm.PREADY) @(vif.cbm);  //wait for PREADY from Slave

    if(vif.cbm.PWRITE ==1'b1) begin//Collect only write transaction
        pkt.data = vif.cbm.PWDATA ;
        pkt.addr = vif.cbm.PADDR;
        pkt.kind = vif.cbm.PWRITE ==1'b1 ? WRITE:READ;
        mbx.put( pkt);
	pkt.print();
        no_of_pkts_recvd++;
        $display("[apb_iMonitor] Sent apb_trans %0d to scoreboard at time=%0t ",no_of_pkts_recvd,$time); 
    end//end_of_if
    while (vif.cbm.PREADY) @(vif.cbm);  //Wait for Slave to de-asert PREADY

    fork //clear mailbox with the current packet
      begin//Let the Scoreboard and coverage components to sample the packet and then delete the packet in mailbox
  	apb_trans temp;
  	#0 while(mbx.num >= 1) void'(mbx.try_get(temp));
      end
    join_none
end//end_of_forver
endtask

function void report();
$display("[apb_iMonitor] Report: total_apb_transs_received=%0d ",no_of_pkts_recvd); 
endfunction



endclass

