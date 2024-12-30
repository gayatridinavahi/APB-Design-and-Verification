class apb_scoreboard;

bit [31:0] total_pkts_recvd;
apb_trans   ref_pkt;
apb_trans   got_pkt;
mailbox #(apb_trans) mbx_in; //will be connected to input monitor
mailbox #(apb_trans) mbx_out;//will be connected to output monitor
bit [15:0] m_matches;
bit [15:0] m_mismatches;

function new (input mailbox #(apb_trans) mbx_in,
              input mailbox #(apb_trans) mbx_out);

this.mbx_in  = mbx_in;
this.mbx_out = mbx_out;
endfunction

task run ;

$display("[apb_Scoreboard] run started at time=%0t",$time); 
while(1) begin
mbx_in.peek(ref_pkt);
mbx_out.get(got_pkt);
total_pkts_recvd++;
$display("[apb_Scoreboard] apb_trans %0d received at time=%0t",total_pkts_recvd,$time); 
if (ref_pkt.compare(got_pkt) )
begin
    m_matches++;
$display("[apb_Scoreboard] apb_trans %0d Matched ",total_pkts_recvd); 
end
    else
    begin
    m_mismatches++;
    
$display("[apb_Scoreboard] ERROR :: apb_trans %0d Not_Matched at time=%0t",total_pkts_recvd,$time); 
$display("[apb_Scoreboard] *** Expected addr=%0d data=%0d but Received addr=%0d data=%0d ****",ref_pkt.addr,ref_pkt.data,got_pkt.addr,got_pkt.data); 
end
    
end
endtask

function void report();
$display("[apb_Scoreboard] Report: total_apb_transs_received=%0d ",total_pkts_recvd); 
$display("[apb_Scoreboard] Report: Matches=%0d Mis_Matches=%0d ",m_matches,m_mismatches); 
endfunction

endclass

