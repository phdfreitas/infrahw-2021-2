-- falta verificar os bites de entrada 
module mux_shamtControl (
    input  wire    [1:0]   selector,
    input  wire    [10:0]  Data_0,    --shamt[10:6]
    input  wire    [31:0]  Data_2,    
    input  wire    [31:0]  Data_3,    --B
    output wire    [31:0]  Data_out 
);

    wire [31:0] OX;
    wire [31:0] IX;
    
    -- verificar os bits que serão pegos
    assign OX       = (selector[0]) ? 32'b00000000000000000000000000010000 : Data_0[10:6];  --16
    assign IX       = (selector[0]) ? Data_3 : Data_2;
    assign Data_out = (selector[1]) ? IX : OX;
    
endmodule