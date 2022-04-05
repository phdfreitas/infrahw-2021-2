module F_mux_regData (
    input  wire  [2:0]    selector,   //MemToReg
    input  wire  [31:0]   Data_0,
    input  wire  [31:0]   Data_1,
    input  wire  [31:0]   Data_2,
    input  wire  [31:0]   Data_3,    //(227)
    input  wire  [31:0]   Data_4,
    input  wire  [31:0]   Data_5,
    input  wire  [31:0]   Data_6,
    output wire  [31:0]   Data_out
);

    wire [31:0] W1;
    wire [31:0] W2;
    wire [31:0] W3;
    wire [31:0] W4;
    wire [31:0] W5;

    assign W1       = (selector[0]) ? Data_1 : Data_0;  
    assign W2       = (selector[0]) ? Data_3 : Data_2;
    assign W3       = (selector[0]) ? Data_5 : Data_4;

    assign W4       = (selector[1]) ? W2 : W1;
    assign W5       = (selector[1]) ? Data_6 : W3;

    assign Data_out = (selector[2]) ? W5 : W4;

endmodule