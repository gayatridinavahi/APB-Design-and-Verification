class apb_coverage;
real coverage_score;
apb_trans pkt;
mailbox #(apb_trans) mbx;//will be connected to input of scoreboard

covergroup apb_cov with function sample(apb_trans pkt) ;
   option.comment="Coverage for APB ";
   addr:coverpoint pkt.addr { // Measure apb_coverage
      bins apb_addr[] = {[0:255]};
   }

   mode:coverpoint pkt.kind {
       bins write = {WRITE};
       bins read  = {READ};
   }
endgroup
   
function new (input mailbox #(apb_trans) mbx_in);
this.mbx = mbx_in;
apb_cov=new;
endfunction

virtual task run();
$display("[Coverage] run started at time=%0t",$time);
while(1) begin
@(mbx.num);
mbx.peek(pkt);
apb_cov.sample(pkt);
coverage_score = apb_cov.get_coverage();
$display("[Coverage] Coverage=%0f ",coverage_score);
end
endtask

function void report();
$display("********* Functional Coverage **********");
$display("[apb_coverage] coverage_score=%0f ",coverage_score);
$display("**************************************");
endfunction
endclass

