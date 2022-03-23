module mux_ALU_control (
    input  wire    [1:0]   selector,
    input  wire    [2:0]   ALU_op,
    input  wire    [5:0]   funct,
    output wire    [2:0]   data_out    // confirmar se é 3 bits na saida   
);


    
    assign OX       = (selector[0]) ? 32'b00000000000000000000000000011101 : Data_0;
    assign IX       = (selector[0]) ? Data_3[15-11] : 32'b00000000000000000000000000011111;
    assign Data_out = (selector[1]) ? IX : OX;
    
endmodule