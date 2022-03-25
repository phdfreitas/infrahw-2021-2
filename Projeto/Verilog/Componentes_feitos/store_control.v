module store_control(
    input   wire [31:0] B,        // Menos significativos
    input   wire [31:0] mdr_data, // Pega os mais significativos
    input   wire [1:0]  store_control_sign,
    output  wire [31:0] store_control_out;
);

    wire [31:0] SHB;

    assign SHB = (store_control_sign[0]) ? {mdr_data[31:16], B[15:0]} : {mdr_data[31:8], B[7:0]};
    assign store_control_out = (store_control_sign[1]) SHB ? : B;
endmodule