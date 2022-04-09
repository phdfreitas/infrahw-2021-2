module F_mux_shamtControl (
    input  wire    [1:0]   selector,
    input  wire    [4:0]   Data_0,
    input  wire    [4:0]   Data_1,
    input  wire    [4:0]   Data_2,    
    input  wire    [4:0]   Data_3,
    output wire    [4:0]   Data_out 
);

    wire [4:0] W1;
    wire [4:0] W2;
    
    assign W1       = (selector[0]) ? Data_1 : Data_0;
    assign W2       = (selector[0]) ? Data_3 : Data_2;
    assign Data_out = (selector[1]) ? W2 : W1;
    
endmodule