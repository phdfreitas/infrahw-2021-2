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
    output reg PC_write_cond,
    output reg MEMRead,
    output reg IRWrite,
    output reg RegWrite,
    output reg A_write,
    output reg B_write,
    output reg MDR_load,
    output reg EPCWrite,
    output reg AluOutWrite,


    // Sinais de controle dois dígitos
    output reg [1:0] RegDst,
    output reg [1:0] ALUSourceA,
    output reg [1:0] storeControl,
    output reg [1:0] loadSizeControl,
    output reg [1:0] shamtControl,
    output reg       shiftSourceControl, // posicionar no lugar correto depois

    // Controles de três dígitos
    output reg [2:0] IorD,
    output reg [2:0] MemToReg,
    output reg [2:0] ALUSourceB,
    output reg [2:0] AluOp,
    output reg [2:0] PCSource
);

// Variáveis Internas
reg [5:0] STATE;

// Constantes (Se refere a cada estado)
parameter RESET             = 6'd0;
parameter INSTRUCTION_FETCH = 6'd1;
parameter WAIT              = 6'd2;
parameter WAIT_2            = 6'd3;
parameter DECODE            = 6'd4;
parameter DECODE_WAIT       = 6'd5; // Serve pra fechar a escrita nos REG_A e REG_B antes de começar qualquer outra coisa
parameter ADD               = 6'd6;
parameter SUB               = 6'd7;
parameter AND               = 6'd8;
parameter ADDI              = 6'd9;
parameter END_ADD_SUB_AND   = 6'd10;
parameter END_IMMEDIATE     = 6'd11;
parameter ATRASA_PROX_INSTR = 6'd12; // Monitor tinha falado pra retardar alguma instrução, agora todas são retartadas em 1 step

/*parameter DIV               = 6'd10;
parameter MULT              = 6'd10;
parameter JR                = 6'd10;
parameter MFHI              = 6'd10;
parameter MFLO              = 6'd10;
parameter SLL               = 6'd10;
parameter SLLV              = 6'd10;
parameter SLT               = 6'd10;
parameter SRA               = 6'd10;
parameter SRAV              = 6'd10;
parameter SRL               = 6'd10;
parameter BREAK             = 6'd10;
parameter RTE               = 6'd10;
parameter ADDM              = 6'd10;
//I FORMAT
parameter ADDIU             = 6'd10;
parameter BEQ               = 6'd10;
parameter BNE               = 6'd10;
parameter BLE               = 6'd10;
parameter BGT               = 6'd10;
parameter SLLM               = 6'd10;
...
*/

initial begin
    STATE = INSTRUCTION_FETCH;
end

always @(posedge clk) begin
    if (reset) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd1; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd1; // 
            ALUSourceA          = 2'd0;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3; //
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            PCSource            = 3'd0;

            STATE = INSTRUCTION_FETCH;
    end
    else begin
        if(STATE == INSTRUCTION_FETCH) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd1; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd1; // 
            ALUSourceA          = 2'd0; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd1; //
            AluOp               = 3'd1; //
            PCSource            = 3'd0;

            STATE = WAIT;
        end
    
        else if(STATE == WAIT) begin
            PC_write            = 1'd1; // 
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd1;
            AluOp               = 3'd1; //
            PCSource            = 3'd0;

            STATE = WAIT_2;
        end

        else if(STATE == WAIT_2) begin
            PC_write            = 1'd0; //
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd1; //
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd1; //
            AluOp               = 3'd0;
            PCSource            = 3'd0;

            STATE = DECODE;
        end

        else if(STATE == DECODE) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0; // 
            RegWrite            = 1'd0;
            A_write             = 1'd1; //
            B_write             = 1'd1; //
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0; 
            AluOutWrite         = 1'd1; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0; 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd4; //
            AluOp               = 3'd1; //
            PCSource            = 3'd0;

            STATE = DECODE_WAIT;
        end

        else if(STATE == DECODE_WAIT) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0; //
            B_write             = 1'd0; //
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd1;
            PCSource            = 3'd0;

            case (opcode)    
                6'h0: begin         // Se o OPCODE = 0x0, então é uma operação do tipo R
                    case (funct)    // Logo, o que vai diferir, é o campo funct
                        6'h20: begin
                            STATE = ADD;
                        end
                        6'h22: begin
                            STATE = SUB;
                        end
                        6'h24: begin
                            STATE = AND;
                        end
                    endcase
                end
                // I type
                6'h8: begin
                    STATE = ADDI;
                end
            endcase
        end

        else if(STATE == ADD) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd1; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd1; //
            PCSource            = 3'd0;

            STATE = END_ADD_SUB_AND;
        end

        else if(STATE == SUB) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd1; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd2; //
            PCSource            = 3'd0;

            STATE = END_ADD_SUB_AND;
        end

        else if(STATE == AND) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd1; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd3; //
            PCSource            = 3'd0;

            STATE = END_ADD_SUB_AND;
        end

        else if(STATE == END_ADD_SUB_AND) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd1; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; //

            RegDst              = 2'd3; //
            ALUSourceA          = 2'd0; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd0; //
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == ADDI) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd1; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; //
            AluOp               = 3'd1; //
            PCSource            = 3'd0;

            STATE = END_IMMEDIATE;
        end

        else if(STATE == END_IMMEDIATE) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd1; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd0; //
            ALUSourceA          = 2'd0;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == ATRASA_PROX_INSTR) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            PCSource            = 3'd0;

            STATE = INSTRUCTION_FETCH;
        end
    end
end
endmodule