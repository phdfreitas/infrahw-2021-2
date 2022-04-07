module F_load_size(
    input   wire  [1:0]   load_size_control, 
    input   wire  [31:0]  mdr_input,
    output  wire  [31:0]  load_size_out
);
    
    wire [31:0] LWH; // valor de lh ou lb

    // se o bit mais a direita for 1, então é lh, caso contrário é lw
    assign LWH = (load_size_control[0]) ? {{16'd0}, mdr_input[15:0]} : mdr_input;

    // caso o valor do bit mais a esquerda seja 1, então é lb, caso contrário, é o valor de lhb
    assign load_size_out = (load_size_control[1]) ? {{24'd0}, mdr_input[7:0]} : LWH;  
endmodule