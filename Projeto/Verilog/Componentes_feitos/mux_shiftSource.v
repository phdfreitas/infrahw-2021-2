-- falta verificar os bites de entrada 
module mux_shiftSource (
    input  wire            selector,
    input  wire    [31:0]  Data_0,  --A
    input  wire    [31:0]  Data_1,  --B
    output wire    [31:0]  Data_out 
);

    assign Data_out = (selector) ? Data_1 : Data_0;
    
endmodule