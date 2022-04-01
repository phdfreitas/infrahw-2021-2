module F_ctrl_unit(
    input wire clk,
    input wire reset,
    
    input wire overflow,
    input wire negativo,
	input wire zero,
	input wire igual,
	input wire gt,
	input lt,
    
    //input wire divZero, 

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

    output reg [2:0] AluOp,
    output reg       AluOutWrite,

    output reg reset_out
);

// Variáveis Internas
reg [4:0] STATE;

// Constantes (Se refere a cada estado)
parameter RESET             = 5'd0;
parameter INSTRUCTION_FETCH = 5'd1;
parameter WAIT              = 5'd2;
parameter DECODE            = 5'd3;
parameter ADD               = 5'd4;
parameter AND               = 5'd5;
parameter SUB               = 5'd6;
parameter END_R             = 5'd7;


initial begin
    reset_out = 1'd1;
end

always @(posedge clk) begin
    if (reset) begin
        if (STATE != RESET) begin
            STATE = RESET;

            PC_write    = 1'd0;
            MEMRead     = 1'd0;
            IRWrite     = 1'd0;
            RegWrite    = 1'd0;
            A_write     = 1'd0;
            B_write     = 1'd0;
            IorD        = 3'd0;
            RegDst      = 2'd0;
            MemToReg    = 3'd0;
            ALUSourceA  = 2'd0;
            ALUSourceB  = 3'd0;
            PCSource    = 3'd0;

            AluOp       = 3'd0;
            AluOutWrite = 1'd0;

            reset_out   = 1'd1;
        end
        else begin
            STATE = INSTRUCTION_FETCH;

            PC_write    = 1'd0;
            MEMRead     = 1'd0;
            IRWrite     = 1'd0;
            RegWrite    = 1'd1;
            A_write     = 1'd0;
            B_write     = 1'd0;
            IorD        = 3'd0;
            RegDst      = 2'd1;
            MemToReg    = 3'd3;
            ALUSourceA  = 2'd0;
            ALUSourceB  = 3'd0;
            PCSource    = 3'd0;

            AluOp       = 3'd0;
            AluOutWrite = 1'd0;

            reset_out   = 1'd0;
        end
    end
    else begin
        if(STATE == INSTRUCTION_FETCH) begin
            STATE = WAIT;

            PC_write    = 1'd1;
            MEMRead     = 1'd0;
            IRWrite     = 1'd1;
            RegWrite    = 1'd0;
            A_write     = 1'd0;
            B_write     = 1'd0;
            IorD        = 3'd0;
            RegDst      = 2'd1;
            MemToReg    = 3'd3;
            ALUSourceA  = 2'd0;
            ALUSourceB  = 3'd1;
            PCSource    = 3'd0;

            AluOp       = 3'd1;
            AluOutWrite = 1'd0;

            reset_out   = 1'd0;
        end
    
        else if(STATE == WAIT) begin
            STATE = DECODE;

            PC_write    = 1'd0;
            MEMRead     = 1'd0;
            IRWrite     = 1'd1;
            RegWrite    = 1'd0;
            A_write     = 1'd0;
            B_write     = 1'd0;
            IorD        = 3'd0;
            RegDst      = 2'd1;
            MemToReg    = 3'd3;
            ALUSourceA  = 2'd0;
            ALUSourceB  = 3'd1;
            PCSource    = 3'd0;

            AluOp       = 3'd1;
            AluOutWrite = 1'd0;

            reset_out   = 1'd0;
        end

        else if(STATE == DECODE) begin
            PC_write    = 1'd0;
            MEMRead     = 1'd0;
            IRWrite     = 1'd0;
            RegWrite    = 1'd0;
            A_write     = 1'd1;
            B_write     = 1'd1;
            IorD        = 3'd0;
            RegDst      = 2'd0;
            MemToReg    = 3'd3;
            ALUSourceA  = 2'd0;
            ALUSourceB  = 3'd4;
            PCSource    = 3'd0;
            
            AluOp       = 3'd1;
            AluOutWrite = 1'd1;

            reset_out   = 1'd0;

            case (opcode)    
                8'h0: begin         // Se o OPCODE = 0x0, então é uma operação do tipo R
                    case (funct)    // Logo, o que vai diferir, é o campo funct
                        8'h20: begin
                            STATE = ADD;
                        end
                        8'h24: begin
                            STATE = AND;
                        end
                    endcase
                end

                // Fazer opCodes do tipo I
                // Fazer opCodes do tipo J 
            endcase
        end

        else if(STATE == ADD) begin
            STATE = END_R;

            PC_write    = 1'd0;
            MEMRead     = 1'd0;
            IRWrite     = 1'd0;
            RegWrite    = 1'd0;
            A_write     = 1'd1;
            B_write     = 1'd1;
            IorD        = 3'd0;
            RegDst      = 2'd0;
            MemToReg    = 3'd3;
            ALUSourceA  = 2'd1;
            ALUSourceB  = 3'd0;
            PCSource    = 3'd0;
            AluOp       = 3'd1;
            AluOutWrite = 1'd1;

            reset_out   = 1'd0;
        end

        else if(STATE == END_R) begin
            STATE = INSTRUCTION_FETCH;

            PC_write    = 1'd0;
            MEMRead     = 1'd0;
            IRWrite     = 1'd0;
            RegWrite    = 1'd1;
            A_write     = 1'd1;
            B_write     = 1'd1;
            IorD        = 3'd0;
            RegDst      = 2'd3;
            MemToReg    = 3'd0;
            ALUSourceA  = 2'd1;
            ALUSourceB  = 3'd0;
            PCSource    = 3'd0;
            
            AluOp       = 3'd1;
            AluOutWrite = 1'd1;

            reset_out   = 1'd0;
        end

        else if(STATE == RESET) begin
            STATE = RESET;

            PC_write    = 1'd0;
            MEMRead     = 1'd0;
            IRWrite     = 1'd0;
            RegWrite    = 1'd0;
            A_write     = 1'd0;
            B_write     = 1'd0;
            IorD        = 3'd0;
            RegDst      = 2'd0;
            MemToReg    = 3'd0;
            ALUSourceA  = 2'd0;
            ALUSourceB  = 3'd0;
            PCSource    = 3'd0;

            AluOp       = 3'd0;
            AluOutWrite = 1'd0;

            reset_out   = 1'd1;
        end

    end
end

endmodule