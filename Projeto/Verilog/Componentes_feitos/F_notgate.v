module F_notgate (
    input wire     data_in,
    output wire    data_out
);

assign data_out  =  !data_in;
//assign data_out = (data_in) ? 1'b0 : 1'b1;

endmodule