class apb_environment;
  bit [31:0] no_of_pkts;//assigned in testcase
mailbox #(apb_trans) gen_drv_mbox; //will be connected to generator and driver
mailbox #(apb_trans) mon_in_scb_mbox;//will be connected to input monitor and mon_in in scoreborad
mailbox #(apb_trans) mon_out_scb_mbox;//will be connected to output monitor and mon_out in scoreborad
virtual apb_if.drvr     vif;
virtual apb_if.Mon vif_mon_in;
virtual apb_if.Mon vif_mon_out;

apb_generator  apb_gen;
apb_driver     apb_drvr;
apb_iMonitor   apb_mon_in;
apb_oMonitor   apb_mon_out;
apb_scoreboard apb_scb;
apb_coverage   apb_cov;


function new (input virtual apb_if.drvr vif_in,
              input virtual apb_if.Mon vif_mon_in,
              input virtual apb_if.Mon vif_mon_out,
              input bit [31:0] no_of_pkts);
this.vif= vif_in;
this.vif_mon_in=vif_mon_in;
this.vif_mon_out=vif_mon_out;
this.no_of_pkts=no_of_pkts;
endfunction

function void build();
$display("[apb_environment] build started at time=%0t",$time); 
gen_drv_mbox      = new(1);
mon_in_scb_mbox   = new;
mon_out_scb_mbox  = new;
apb_gen               = new(gen_drv_mbox,no_of_pkts);
apb_drvr              = new(gen_drv_mbox,vif);
apb_mon_in            = new(mon_in_scb_mbox,vif_mon_in);
apb_mon_out           = new(mon_out_scb_mbox,vif_mon_out);
apb_scb               = new(mon_in_scb_mbox,mon_out_scb_mbox);
apb_cov               = new(mon_in_scb_mbox);
$display("[apb_environment] build ended at time=%0t",$time); 
endfunction

task run ;
$display("[apb_environment] run started at time=%0t",$time); 


//Start all the components of apb_environment
fork
apb_gen.run();//start the generator
apb_drvr.run();
apb_mon_in.run();
apb_mon_out.run();
apb_scb.run();
apb_cov.run();
join_any
  
  wait(apb_scb.total_pkts_recvd == no_of_pkts);//Test termination
  
repeat(10) @(vif.cb);
report();
$display("[apb_environment] run ended at time=%0t",$time); 
endtask

function void report();
$display("\n[apb_environment] ****** Report Started ********** "); 
apb_gen.report();
apb_drvr.report();
apb_mon_in.report();
apb_mon_out.report();
apb_scb.report();
apb_cov.report();

$display("\n*****************************************"); 
if(apb_scb.m_mismatches ==0 && (no_of_pkts == apb_scb.total_pkts_recvd) ) begin
$display("***********TEST PASSED ************ ");
$display("*****Functional_coverage=%0f *****",apb_cov.coverage_score);
$display("Matches=%0d Mis_matches=%0d",apb_scb.m_matches,apb_scb.m_mismatches); 
end
else begin
$display("*********TEST FAILED ************ "); 
$display("Matches=%0d Mis_matches=%0d",apb_scb.m_matches,apb_scb.m_mismatches); 
end

$display("*********************************\n "); 

$display("[apb_environment] ******** Report ended******** \n"); 
endfunction

endclass
