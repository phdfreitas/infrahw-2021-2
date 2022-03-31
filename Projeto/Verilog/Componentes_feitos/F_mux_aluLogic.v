module F_mux_aluLogic (
    input  wire    [1:0]   selector,
    input  wire    Data_0,
    input  wire    Data_1,
    input  wire    Data_2,
    input  wire    Data_3, 
    output wire    Data_out 
);

    wire [31:0] OX;
    wire [31:0] IX;
    
    assign OX       = (selector[0]) ? Data_1 : Data_0;
    assign IX       = (selector[0]) ? Data_3 : Data_2;
    assign Data_out = (selector[1]) ? IX : OX;
    
endmodule