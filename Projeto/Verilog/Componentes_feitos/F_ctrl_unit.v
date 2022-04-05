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
    output reg [1:0] ALULogic,

    // Controles de três dígitos
    output reg [2:0] IorD,
    output reg [2:0] MemToReg,
    output reg [2:0] ALUSourceB,
    output reg [2:0] AluOp,
    output reg [2:0] ShiftControl,
    output reg [2:0] PCSource
);

// Variáveis Internas
reg [5:0] STATE;

// Constantes (Se refere a cada estado)
// --------- COMMOM STEPS --------- 
parameter RESET             = 6'd0;
parameter INSTRUCTION_FETCH = 6'd1;
parameter WAIT              = 6'd2;
parameter WAIT_2            = 6'd3;
parameter DECODE            = 6'd4;
parameter DECODE_WAIT       = 6'd5; // Serve pra fechar a escrita nos REG_A e REG_B antes de começar qualquer outra coisa

// ----- R FORMAT INSTRUCTIONS -----
parameter ADD               = 6'd6;
parameter AND               = 6'd7;
parameter SUB               = 6'd8;
parameter DIV               = 6'd10;
parameter MULT              = 6'd11;
parameter JR                = 6'd12;
parameter MFHI              = 6'd13;
parameter MFLO              = 6'd14;
parameter SLL               = 6'd15;
parameter SLLV              = 6'd16;
parameter SLT               = 6'd17;
parameter SRA               = 6'd18;
parameter SRAV              = 6'd19;
parameter SRL               = 6'd20;
parameter BREAK             = 6'd21;
parameter RTE               = 6'd22;
parameter ADDM              = 6'd23;
//
// ----- I FORMAT INSTRUCTIONS -----
parameter ADDI              = 6'd24;
parameter ADDIU             = 6'd25;
parameter BEQ               = 6'd26;
parameter BNE               = 6'd27;
parameter BLE               = 6'd28;
parameter BGT               = 6'd29;
parameter SLLM              = 6'd30;
parameter LB                = 6'd31;
parameter LH                = 6'd32;
parameter LUI               = 6'd33;
parameter LW                = 6'd34;
parameter SB                = 6'd35;
parameter SH                = 6'd36;
parameter SLTI              = 6'd37;
parameter SW                = 6'd38;
//
// ----- J FORMAT INSTRUCTIONS -----
parameter J                 = 6'd39;
parameter JAL               = 6'd40;
//
// ----- END AND EXTRAS INSTRUCTIONS -----
parameter END_ADD_SUB_AND   = 6'd41;
parameter END_IMMEDIATE     = 6'd42;
parameter ATRASA_PROX_INSTR = 6'd43; // Monitor tinha falado pra retardar alguma instrução, agora todas são retartadas em 1 step
parameter SHIFT_WITH_SHAMT  = 6'd44;
parameter SHIFT_WITH_RT     = 6'd45;
parameter END_SHIFT         = 6'd46;
parameter SHIFT_WAIT        = 6'd47;
parameter END_SLT_SLTI      = 6'd48;
//
//
// ----- OPCODE AND FUNCT VALUE (R FORMAT INSTRUCTIONS) -----
parameter R_FORMAT_OPCODE    = 6'h0;
parameter R_FORMAT_ADD       = 6'h20;
parameter R_FORMAT_AND       = 6'h24;
parameter R_FORMAT_DIV       = 6'h1A;
parameter R_FORMAT_MULT      = 6'h18;
parameter R_FORMAT_JR        = 6'h8;
parameter R_FORMAT_MFHI      = 6'h10;
parameter R_FORMAT_MHLO      = 6'h12;
parameter R_FORMAT_SLL       = 6'h0;
parameter R_FORMAT_SLLV      = 6'h4;
parameter R_FORMAT_SLT       = 6'h2A;
parameter R_FORMAT_SRA       = 6'h3;
parameter R_FORMAT_SRAV      = 6'h7;
parameter R_FORMAT_SRL       = 6'h2;
parameter R_FORMAT_SUB       = 6'h22;
parameter R_FORMAT_BREAK     = 6'hD;
parameter R_FORMAT_RTE       = 6'h13;
parameter R_FORMAT_ADDM      = 6'h5;

// ----- OPCODE AND FUNCT VALUE (R FORMAT INSTRUCTIONS) -----
parameter I_FORMAT_SLTI    = 6'hA;

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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3; //
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd1; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd1;
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd1; //
            AluOp               = 3'd0;
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd4; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd1;
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            case (opcode)    
                R_FORMAT_OPCODE: begin         // Se o OPCODE = 0x0, então é uma operação do tipo R
                    case (funct)    // Logo, o que vai diferir, é o campo funct
                        R_FORMAT_ADD: begin
                            STATE = ADD;
                        end
                        R_FORMAT_SUB: begin
                            STATE = SUB;
                        end
                        R_FORMAT_AND: begin
                            STATE = AND;
                        end
                        R_FORMAT_SLL: begin
                            STATE = SHIFT_WITH_SHAMT;
                        end
                        R_FORMAT_SRL: begin
                            STATE = SHIFT_WITH_SHAMT;
                        end
                        R_FORMAT_SRA: begin
                            STATE = SHIFT_WITH_SHAMT;
                        end
                        R_FORMAT_SRAV: begin
                            STATE = SHIFT_WITH_RT;
                        end
                        R_FORMAT_SLLV: begin
                            STATE = SHIFT_WITH_RT;
                        end
                        R_FORMAT_SLT: begin
                            STATE = SLT;
                        end
                    endcase
                end
                // I type
                6'h8: begin
                    STATE = ADDI;
                end
                I_FORMAT_SLTI: begin
                    STATE = SLTI;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd2; //
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd3; //
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd0; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == SHIFT_WITH_SHAMT) begin
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
            shamtControl        = 2'd0; //
            shiftSourceControl  = 1'd1; //
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd1; //
            PCSource            = 3'd0;

            if(funct == R_FORMAT_SLL) begin
                STATE = SLL;
            end
            else if(funct == R_FORMAT_SRA) begin
                STATE = SRA; 
            end
            else if(funct == R_FORMAT_SRL) begin 
                STATE = SRL;
            end
        end

        else if(STATE == SHIFT_WITH_RT) begin
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
            shamtControl        = 2'd3; //
            shiftSourceControl  = 1'd0; //
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd1; //
            PCSource            = 3'd0;

            if(funct == R_FORMAT_SLLV) begin
                STATE = SLLV;
            end
            else if(funct == R_FORMAT_SRAV) begin
                STATE = SRAV; 
            end
        end

        else if(STATE == SLL) begin
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
            shamtControl        = 2'd0; //
            shiftSourceControl  = 1'd1; //
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd2; //
            PCSource            = 3'd0;

            STATE = SHIFT_WAIT;
        end

        else if(STATE == SRL) begin
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd3; //
            PCSource            = 3'd0;

            STATE = SHIFT_WAIT;
        end

        else if(STATE == SRA) begin
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd4; //
            PCSource            = 3'd0;

            STATE = SHIFT_WAIT;
        end

        else if(STATE == SLLV) begin
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd2; //
            PCSource            = 3'd0;

            STATE = SHIFT_WAIT;
        end

        else if(STATE == SRAV) begin
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd4; //
            PCSource            = 3'd0;

            STATE = SHIFT_WAIT;
        end

        else if(STATE == SHIFT_WAIT) begin
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
            shamtControl        = 2'd0; //
            shiftSourceControl  = 1'd0; //
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd0; //
            PCSource            = 3'd0;

            STATE = END_SHIFT;
        end

        else if(STATE == END_SHIFT) begin
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

            RegDst              = 2'd3; //
            ALUSourceA          = 2'd0;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0; 
            shiftSourceControl  = 1'd0;
            ALULogic            = 2'd0; 

            IorD                = 3'd0;
            MemToReg            = 3'd2; // 
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == SLT) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd1;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd3;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0; 
            shiftSourceControl  = 1'd0;
            ALULogic            = 2'd0; 

            IorD                = 3'd0;
            MemToReg            = 3'd4; 
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd7; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end
//////////////////////////////////////////////////////////////////////////////////////
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd0;
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
            ALULogic            = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = INSTRUCTION_FETCH;
        end
    end
end
endmodule