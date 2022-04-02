module F_mux_writeReg (
    input wire selector,
    input wire [4:0] Data_0,
    input wire [15:0] Data_1,
    output wire [4:0] Data_out
);

    assign Data_out = (selector) ? Data_1[15:11] : Data_0;

endmodule