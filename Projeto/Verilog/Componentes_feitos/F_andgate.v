module F_andgate(
    input  wire  mux_branch_out,
    input  wire  PC_write_cond,
    output wire  and_out
);

assign and_out = mux_branch_out & PC_write_cond;

endmodule