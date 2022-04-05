module F_orgate(
    input  wire   branch_signal,
    input  wire   PC_write_UC,
    output wire   PC_write
);


assign PC_write = branch_signal | PC_write_UC;

endmodule