class apb_trans ;

rand logic [31:0] addr;
rand logic [31:0] data;

status_e status;
kind_e   kind;

bit [7:0] reset_cycles;

constraint valid {
    //addr inside {[0:255]};
  addr inside {[1:9]};
    data inside {[10:500]};
}

virtual function void print();
$display("APB %0s addr=0x%0h data=0x%0h",kind.name(),addr,data);
endfunction

function void copy (apb_trans rhs);
if(rhs==null) begin
    $display("[apb_trans] Error Null object passed to copy method ");
    return;
end
this.addr=rhs.addr;
this.data=rhs.data;
endfunction

function bit compare (apb_trans rhs);
bit result;

if(rhs==null) begin
    $display("[apb_trans] Error Null object passed to compare method ");
    return 0;
end
result = (this.addr == rhs.addr) & (this.data == rhs.data);
return result;
endfunction

endclass


