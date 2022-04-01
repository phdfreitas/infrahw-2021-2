module F_mux_ulaB (
    input  wire    [2:0]   selector,
    input  wire    [31:0]  Data_0,
    input  wire    [31:0]  Data_1,
    input  wire    [31:0]  Data_2,
    input  wire    [31:0]  Data_3,
    input  wire    [31:0]  Data_4,
    input  wire    [31:0]  Data_5, 
    output wire    [31:0]  Data_out 
);

    wire [31:0] W1;
    wire [31:0] W2;
    wire [31:0] W3;
    wire [31:0] W4;

    assign W1       = (selector[0]) ? Data_0 : Data_1; 
    assign W2       = (selector[0]) ? Data_3 : Data_3;
    assign W3       = (selector[0]) ? Data_5 : Data_4;
    assign W4       = (selector[1]) ? W2 : W1;

    assign Data_out = (selector[2]) ? W3 : W4;
    
endmodule