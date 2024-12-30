class apb_base_test;

bit [31:0] no_of_pkts;

virtual apb_if.drvr     vif;
virtual apb_if.Mon vif_mon_in;
virtual apb_if.Mon vif_mon_out;

apb_environment apb_env;

function new (input virtual apb_if.drvr vif_in,
              input virtual apb_if.Mon vif_mon_in,
              input virtual apb_if.Mon vif_mon_out
	     );
this.vif= vif_in;
this.vif_mon_in=vif_mon_in;
this.vif_mon_out=vif_mon_out;
endfunction

function void build();
apb_env = new(vif,vif_mon_in,vif_mon_out,no_of_pkts);
apb_env.build();//contruct the components and connect them
endfunction

task run ();
$display("[Testcase] run started at time=%0t",$time);
no_of_pkts=30;
build();
apb_env.run();
$display("[Testcase] run ended at time=%0t",$time);
endtask


endclass

