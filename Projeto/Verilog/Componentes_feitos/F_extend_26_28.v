module F_extend_26_28(
    input wire [4:0] RS,
    input wire [4:0] RT,
    input wire [15:0] Address_Immediate,

    output wire [27:0] extend_26_28_out
);

    assign extend_26_28_out = {RS, RT, Address_Immediate, 2'b00}; // Só chutei que era no menos signigicativo, pode ser no mais signigicativo tbm, perguntar ao monitor

endmodule