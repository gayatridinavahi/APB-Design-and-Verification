class apb_generator;

bit [31:0] no_of_pkts;
apb_trans pkt;
apb_trans rand_obj;
mailbox #(apb_trans) mbx;

function new (mailbox #(apb_trans) mbx_in,bit [31:0] gen_pkts_no=1);
this.no_of_pkts= gen_pkts_no;
this.mbx       = mbx_in;
rand_obj=new;
endfunction

task run ;
bit [31:0] pkt_count;
$display("[apb_Generator] run started at time=%0t",$time); 

//generate First apb_trans as Reset apb_trans
pkt=new;
pkt.kind=RESET;
pkt.reset_cycles=2;
$display("[apb_Generator] Sending %0s apb_trans to driver at time=%0t",pkt.kind.name(),$time); 
mbx.put(pkt);

//generate the NORMAL Stimulus
repeat(no_of_pkts) begin
void'(rand_obj.randomize());
pkt=new;
pkt.copy(rand_obj);
pkt.kind=STIMULUS;
mbx.put(pkt);
pkt_count++;
$display("[apb_Generator] Sent %0s apb_trans %0d to driver at time=%0t",pkt.kind.name(),pkt_count,$time); 
end

$display("[apb_Generator] run ended at time=%0t",$time); 
endtask

function void report();
$display("[apb_Generator]  Report: total_apb_transs_generated=%0d ",no_of_pkts); 
endfunction

endclass

