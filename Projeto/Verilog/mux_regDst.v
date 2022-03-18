module mux_regDst (
    input  wire    [1:0]   selector,
    input  wire    [5:0]  Data_0,
    input  wire    [15:0]  Data_3, 
    output wire    [4:0]  Data_out 
);

    wire [31:0] ZX;
    wire [31:0] IX;
    
    assign OX       = (selector[0]) ? 32'b00000000000000000000000000011101 : Data_0;
    assign IX       = (selector[0]) ? Data_3[15-11] : 32'b00000000000000000000000000011111;
    assign Data_out = (selector[1]) ? IX : OX;
    
endmodule