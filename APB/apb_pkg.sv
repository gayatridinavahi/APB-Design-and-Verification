package apb_pkg;

typedef enum {IDEL,RESET,STIMULUS,READ,WRITE} kind_e; 
typedef enum {NOT_OK,OK,ERROR} status_e; 

`include "apb_transaction.sv"
`include "apb_generator.sv"
`include "apb_driver.sv"
`include "apb_iMonitor.sv"
`include "apb_oMonitor.sv"
`include "apb_scoreboard.sv"
`include "apb_coverage.sv"
`include "apb_environment.sv"

endpackage 

