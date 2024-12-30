class apb_oMonitor ;

bit [31:0] no_of_pkts_recvd;
apb_trans   tr;
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
$display("[apb_oMonitor] run started at time=%0t ",$time); 

forever begin 
	@(vif.cbm.PRDATA);
        //skip the loop when data_out is in high impedance state
	if(vif.cbm.PRDATA === 'z || vif.cbm.PRDATA === 'x) continue;
    
	tr = new;
	
        if(vif.cbm.PWRITE ==1'b0) begin//Collect only READ transaction
           tr.data = vif.cbm.PRDATA ;
      	   tr.addr = vif.cbm.PADDR;
	   tr.kind = vif.cbm.PWRITE ==1'b1 ? WRITE:READ;
	   mbx.put(tr);
           no_of_pkts_recvd++;
           $display("[apb_oMonitor] Sent apb_trans %0d to scoreboard at time=%0t ",no_of_pkts_recvd,$time); 
           tr.print();
	end// end_of_if
end//end_of_forever
endtask

function void report();
$display("[apb_oMonitor] Report: total_apb_transs_received=%0d ",no_of_pkts_recvd); 
endfunction



endclass

