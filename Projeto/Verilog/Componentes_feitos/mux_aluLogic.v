-- falta verificar os bites de entrada e os numeros negativos

module mux_aluLogic (
    input  wire    [1:0]   selector,
    input  wire    [31:0]  Data_0,
    input  wire    [31:0]  Data_1,
    input  wire    [31:0]  Data_2,
    input  wire    [31:0]  Data_3, 
    output wire    [31:0]  Data_out 
);

    wire [31:0] OX;
    wire [31:0] IX;
    
    -- verificar os bits que serão pegos
    assign OX       = (selector[0]) ? Data_1 : Data_0;
    assign IX       = (selector[0]) ? Data_3 : Data_2;
    assign Data_out = (selector[1]) ? IX : OX;
    
endmodule