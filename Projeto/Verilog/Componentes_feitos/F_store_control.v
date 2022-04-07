module F_store_control(
    input   wire [1:0]  store_control_sign,
    input   wire [31:0] B,        // Menos significativos
    input   wire [31:0] mdr_data, // Pega os mais significativos
    output  wire [31:0] store_control_out
);

    wire [31:0] SWH;

    assign SWH = (store_control_sign[0]) ? {mdr_data[31:16], B[15:0]} : B;
    assign store_control_out = (store_control_sign[1]) ? {mdr_data[31:8], B[7:0]} : SWH;
endmodule