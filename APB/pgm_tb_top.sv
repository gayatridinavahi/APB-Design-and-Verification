`include "apb_pkg.sv"

program pgm_tb_top(apb_if apb_pif);

import apb_pkg::*;

`include "apb_base_test.sv"

apb_base_test test;

initial begin
$display("[Program Block] simulation Started at time=%0t",$time);
test=new(apb_pif.drvr,apb_pif.Mon,apb_pif.Mon);
test.run();
$display("[Program Block] simulation finished at time=%0t",$time);
end

endprogram
