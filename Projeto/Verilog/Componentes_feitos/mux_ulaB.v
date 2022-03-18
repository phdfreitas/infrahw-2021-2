module mux_ulaB (
    input  wire    [2:0]   selector,
    input  wire    [31:0]  Data_0,
    input  wire    [31:0]  Data_2,
    input  wire    [31:0]  Data_3,
    input  wire    [31:0]  Data_4,
    input  wire    [31:0]  Data_5, 
    output wire    [31:0]  Data_out 
);

    wire [31:0] OXX;
    wire [31:0] OIX;
    wire [31:0] OOX;

    assign OOX      = (selector[0]) ? Data_0 : 32'b00000000000000000000000000000100;
    assign OIX      = (selector[0]) ? Data_2 : Data_3;
    assign OXX      = (selector[1]) ? OIX : OOX;
    assign Data_out = (selector[2]) ? IOX : OXX;
    
endmodule