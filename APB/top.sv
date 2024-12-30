`include "slave_ip.v"
`include "apb_if.sv"
`include "pgm_tb_top.sv"
module top;

bit PCLK;

always #10 PCLK = ~PCLK;

apb_if apb_if_inst(PCLK);

// DUT
apb_slave_ip apb_slave_ip_inst(
    // APB Interface:
    .PCLK(PCLK),
    .PRESETn(apb_if_inst.PRESETn),
    .PSEL(apb_if_inst.PSEL),
    .PADDR(apb_if_inst.PADDR),
    .PWDATA(apb_if_inst.PWDATA),
    .PRDATA(apb_if_inst.PRDATA),
    .PENABLE(apb_if_inst.PENABLE),
    .PREADY(apb_if_inst.PREADY),
    .PWRITE(apb_if_inst.PWRITE)
);

pgm_tb_top tb_inst(apb_if_inst);

//Dumping Waveform
initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0,top); 
end

endmodule
