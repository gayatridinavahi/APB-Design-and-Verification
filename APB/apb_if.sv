interface apb_if (input logic PCLK);
logic PRESETn;
logic PSEL;
logic PREADY;
logic PENABLE;
logic PWRITE;
logic PSLVERR;//Not Used
logic [31:0] PADDR;
logic [31:0] PWDATA;
wire  [31:0] PRDATA;

//clocking block signal directions are w.r.t testbench
//Master clocking for driver
clocking cb @(posedge PCLK);
output PSEL;
output PENABLE;
output PWRITE;
output PADDR;
output PWDATA;

input  PRDATA;
input  PREADY;
input  PSLVERR;

endclocking

//Monitor clocking block
clocking cbm @(posedge PCLK);
input  PSEL;
input  PREADY;
input  PENABLE;
input  PWRITE;
input  PADDR;
input  PWDATA;
input  PRDATA;
input  PSLVERR;
endclocking


modport drvr (clocking cb ,output PRESETn);
modport Mon (clocking cbm,input PRESETn);

endinterface

