module F_sign_extend_16_32 (
    input  wire            Data_in,
    output wire    [31:0]  Data_out 
);

    assign Data_out = {{31{1'b0}}, Data_in};
    
endmodule