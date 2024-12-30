class apb_driver;

apb_trans   pkt;
mailbox #(apb_trans) mbx;
virtual apb_if.drvr vif;
bit [31:0] no_of_pkts_recvd;

  
function new (input mailbox #(apb_trans) mbx_in,
	      input virtual  apb_if.drvr vif_in);
this.mbx  = mbx_in;
this.vif  = vif_in;
endfunction

extern task run();
extern task drive(apb_trans pkt);
extern task drive_reset(apb_trans pkt);
extern task drive_stimulus(apb_trans pkt);
extern task write(apb_trans pkt);
extern task read(apb_trans pkt);
extern function void report();

endclass


task apb_driver::run();
$display("[apb_driver] run started at time=%0t",$time); 

while(1) begin //apb_driver runs forever 
mbx.get(pkt);
no_of_pkts_recvd++;
$display("[apb_driver] Received  %0s apb_trans %0d from generator at time=%0t",pkt.kind.name(),no_of_pkts_recvd,$time); 
drive(pkt);
$display("[apb_driver] Done with %0s apb_trans %0d from generator at time=%0t",pkt.kind.name(),no_of_pkts_recvd,$time); 
end//end_of_while
endtask

task apb_driver::drive(apb_trans pkt);
case (pkt.kind)
    RESET      : drive_reset(pkt);
    STIMULUS   : drive_stimulus(pkt);
    default    : $display("[Error] Unknown apb_trans received in apb_driver");
endcase
endtask

task apb_driver::drive_reset(apb_trans pkt);
$display("[apb_driver] Applying reset to APB at time=%0t",$time); 
vif.cb.PSEL    <=0;
vif.cb.PENABLE <=0;
vif.cb.PADDR   <='0;
vif.cb.PWDATA  <='0;
vif.PRESETn = 0;
repeat (pkt.reset_cycles) @(vif.cb);
vif.PRESETn = 1;
repeat (2) @(vif.cb);
$display("[apb_driver] APB out of Reset at time=%0t",$time); 
endtask


task apb_driver::drive_stimulus(apb_trans pkt);
    write(pkt);
    read(pkt);
endtask

task apb_driver::write(apb_trans pkt);
@(vif.cb);
$display("[apb_driver] APB write operation started with addr=%0d data=%0d at time=%0t",pkt.addr,pkt.data,$time); 
//SETUP Phase
    @(vif.cb);
    vif.cb.PSEL    <= 1;
    vif.cb.PWRITE  <= 1;
    vif.cb.PADDR   <= pkt.addr;
    vif.cb.PWDATA  <= pkt.data;
    @(vif.cb);
//ACCESS Phase
    vif.cb.PENABLE <=1;
//Wait for PREADY from Slave
    do @(vif.cb); while (!vif.cb.PREADY);
    vif.cb.PENABLE <=0;
    vif.cb.PSEL    <=0;
    vif.cb.PADDR   <='0;
    vif.cb.PWDATA  <='0;
    vif.cb.PWRITE  <= 0;
    //tr.status = vif.cb.PSLVERR == 0 ? OK : ERROR;

$display("[apb_driver] APB write operation ended with addr=%0d data=%0d at time=%0t",pkt.addr,pkt.data,$time); 
endtask

task apb_driver::read(apb_trans pkt);
$display("[apb_driver] APB read operation started with addr=%0d at time=%0t",pkt.addr,$time); 
//SETUP Phase
    @(vif.cb);
    vif.cb.PSEL    <= 1;
    vif.cb.PWRITE  <= 0;
    vif.cb.PADDR   <= pkt.addr;
    @(vif.cb);
//ACCESS Phase
    vif.cb.PENABLE <= 1;
//Wait for PREADY from Slave
    do @(vif.cb); while (!vif.cb.PREADY);
    vif.cb.PENABLE <= 0;
    vif.cb.PSEL    <= 0;
    vif.cb.PADDR   <='0;
    @(vif.cb); 
    pkt.data = vif.cb.PRDATA;
    //pkt.status = vif.cb.PSLVERR == 0 ? OK : ERROR;

$display("[apb_driver] APB read operation ended with addr=%0d at time=%0t",pkt.addr,$time); 
endtask

function void apb_driver::report();
$display("[apb_driver] Report: total_apb_transs_driven=%0d ",no_of_pkts_recvd); 
endfunction

