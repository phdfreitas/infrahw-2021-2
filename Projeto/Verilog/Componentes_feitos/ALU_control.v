module ALU_control (
    input  wire            selector,
    input  wire    [2:0]   ALU_op,
    input  wire    [5:0]   funct,
    output wire    [2:0]   data_out    // confirmar se é 3 bits na saida   
);

    assign Data_out = (selector) ? ALU_op : funct;
    
endmodule