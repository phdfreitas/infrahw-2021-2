module F_ctrl_unit(
    input wire clk,
    input wire reset,
    input wire overflow,
    input wire divZero, 

    input wire [5:0] opcode,
    input wire [5:0] funct,
    // =-=-=-=-=-=-=-=-=-=-=-= //

    // Sinais de controle unitários //
    output reg PC_write,
    output reg MEMRead,
    output reg IRWrite,
    output reg RegWrite,
    output reg A_write,
    output reg B_write,

    // Controladores dos mux (da esquerda para a direita)
    output reg [2:0] IorD,
    output reg [1:0] RegDst,
    output reg [2:0] MemToReg,
    output reg [1:0] ALUSourceA,
    output reg [2:0] ALUSourceB,
    output reg [2:0] PCSource,

    output reg reset_out
);

endmodule