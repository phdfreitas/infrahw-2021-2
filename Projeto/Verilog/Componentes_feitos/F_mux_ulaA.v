module F_mux_ulaA (
    input  wire    [1:0]   selector,
    input  wire    [31:0]  Data_0,
    input  wire    [31:0]  Data_1,
    input  wire    [31:0]  Data_2, 
    output wire    [31:0]  Data_out 
);

    wire [31:0] OX;

    assign OX       = (selector[0]) ? Data_1 : Data_0;
    assign Data_out = (selector[1]) ? Data_2 : OX;
    
endmodule