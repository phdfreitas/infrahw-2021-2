module F_mux_ulaB (
    input wire [1:0] selector,
    input wire [31:0] Data_0,
    input wire [31:0] Data_1,
    output wire [31:0] data_out

); 

    wire [31:0] A1;

    assign A1 = (selector[0]) ? 32'b00000000000000000000000000000100;
    assign Data_out = (selector[1]) ? Data_1 : A1;
    
endmodule