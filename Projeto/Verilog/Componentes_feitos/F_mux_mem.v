module F_mux_mem (
    input  wire  [2:0]    selector,    //IorD
    input  wire  [31:0]   Data_0,
	input  wire  [31:0]   Data_1,		//227
	input  wire  [31:0]   Data_2,		//254
	input  wire  [31:0]   Data_3,		//255
    input  wire  [31:0]   Data_4,
    input  wire  [31:0]   Data_5,
    input  wire  [31:0]   Data_6,
    output wire  [31:0]   Data_out
);

    wire [31:0] XOX;
    wire [31:0] XIX;
    wire [31:0] OXX;
    wire [31:0] IOX;
    wire [31:0] IXX;

    assign XOX      = (selector[0]) ? Data_1 : Data_0;
    assign XIX      = (selector[0]) ? Data_3 : Data_2;
    assign OXX      = (selector[1]) ? XIX    : XOX;
    assign IOX      = (selector[0]) ? Data_5 : Data_4;
    assign IXX      = (selector[1]) ? Data_6 : IOX;
    assign Data_out = (selector[2]) ? IXX    : OXX;

endmodule