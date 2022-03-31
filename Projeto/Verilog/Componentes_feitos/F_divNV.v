module F_div(
    // Entradas do divisor
    input wire clk,         // Clock global
    input wire reset,       // Reset global
    input wire divisor,     // Sinal de comunicação
    input wire [31:0] A,    // Reg A 
    input wire [31:0] B,    // Reg B

    // Saídas do divisor
    output reg HI,          // Vai guardar os 32bits mais significativos      
    output reg LO,          // vai guardar os 32bits menos significativos
    output reg divZero,     // caso seja uma divisão por zero, estoura a exceção
    output reg fim          // controla o fim da execução
);

    // Variáveis auxiliares

endmodule