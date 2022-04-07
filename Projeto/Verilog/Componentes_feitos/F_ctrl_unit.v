module F_ctrl_unit(
    input wire clk,
    input wire reset,
    
    input wire overflow,
    input wire negativo,
	input wire zero,
	input wire igual,
	input wire gt,
	input lt,

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
    output reg [1:0] shiftSourceControl,

    // Controles de três dígitos
    output reg [2:0] IorD,
    output reg [2:0] MemToReg,
    output reg [2:0] ALUSourceB,
    output reg [2:0] AluOp,
    output reg [2:0] ShiftControl,
    output reg [2:0] PCSource
);

// Variáveis Internas
reg [6:0] STATE;

// Constantes (Se refere a cada estado)
// --------- COMMOM STEPS --------- 
parameter RESET             = 7'd0;
parameter INSTRUCTION_FETCH = 7'd1;
parameter WAIT              = 7'd2;
parameter WAIT_2            = 7'd3;
parameter DECODE            = 7'd4;
parameter DECODE_WAIT       = 7'd5; // Serve pra fechar a escrita nos REG_A e REG_B antes de começar qualquer outra coisa

// ----- R FORMAT INSTRUCTIONS -----
parameter ADD               = 7'd6;
parameter AND               = 7'd7;
parameter SUB               = 7'd8;
parameter DIV               = 7'd10;
parameter MULT              = 7'd11;
parameter JR                = 7'd12;
parameter MFHI              = 7'd13;
parameter MFLO              = 7'd14;
parameter SLL               = 7'd15;
parameter SLLV              = 7'd16;
parameter SLT               = 7'd17;
parameter SRA               = 7'd18;
parameter SRAV              = 7'd19;
parameter SRL               = 7'd20;
parameter BREAK             = 7'd21;
parameter RTE               = 7'd22;
parameter ADDM              = 7'd23;
//
// ----- I FORMAT INSTRUCTIONS -----
parameter ADDI              = 7'd24;
parameter ADDIU             = 7'd25;
parameter BEQ               = 7'd26;
parameter BNE               = 7'd27;
parameter BLE               = 7'd28;
parameter BGT               = 7'd29;
parameter SLLM              = 7'd30;
parameter LB                = 7'd31;
parameter LH                = 7'd32;
parameter LUI               = 7'd33;
parameter LW                = 7'd34;
parameter SB                = 7'd35;
parameter SH                = 7'd36;
parameter SLTI              = 7'd37;
parameter SW                = 7'd38;
//
// ----- J FORMAT INSTRUCTIONS -----
parameter J                 = 7'd39;
parameter JAL               = 7'd40;
//
// ----- END AND EXTRAS INSTRUCTIONS -----
parameter END_ADD_SUB_AND   = 7'd41;
parameter END_IMMEDIATE     = 7'd42;
parameter ATRASA_PROX_INSTR = 7'd43; // Monitor tinha falado pra retardar alguma instrução, agora todas são retartadas em 1 step
parameter SHIFT_WITH_SHAMT  = 7'd44;
parameter SHIFT_WITH_RT     = 7'd45;
parameter END_SHIFT         = 7'd46;
parameter SHIFT_WAIT        = 7'd47;
parameter END_SLT_SLTI      = 7'd48;
parameter END_BEQ           = 7'd54;
parameter END_BNE           = 7'd55;
parameter END_BLE           = 7'd56;
parameter END_BGT           = 7'd57;

// ---------- Load Control ----------
parameter LOAD_STORE_COMMON = 7'd49;
parameter LOAD_BASIC_STEP   = 7'd50;
parameter LOAD_INTER_STEP   = 7'd51;
parameter LOAD_FINAL_STEP   = 7'd52;
parameter LW_FINAL          = 7'd53;
parameter LH_FINAL          = 7'd68;
parameter LB_FINAL          = 7'd69;

// ---------- Store Control ----------
parameter STORE_BASIC_STEP  = 7'd58;
parameter STORE_INTER_STEP  = 7'd59;
parameter STORE_FINAL_STEP  = 7'd60;
parameter SW_FINAL          = 7'd61;
parameter SH_FINAL          = 7'd66;
parameter SB_FINAL          = 7'd67;

// ---------- ADDM Instruction ----------
parameter ADDM_STEP2        = 7'd62;
parameter ADDM_STEP3        = 7'd63;
parameter ADDM_STEP4        = 7'd64;
parameter ADDM_STEP5        = 7'd65;
parameter ADDM_STEP6        = 7'd73;
parameter ADDM_STEP7        = 7'd74;
parameter ADDM_FINAL        = 7'd75;

parameter SHIFT_WITH_CTE    = 7'd70;
parameter LUI_WAIT          = 7'd71;
parameter END_LUI           = 7'd72;

//
//
// ----- OPCODE AND FUNCT VALUE (R FORMAT INSTRUCTIONS) -----
parameter R_FORMAT_OPCODE    = 7'h0;
parameter R_FORMAT_ADD       = 7'h20;
parameter R_FORMAT_AND       = 7'h24;
parameter R_FORMAT_DIV       = 7'h1A;
parameter R_FORMAT_MULT      = 7'h18;
parameter R_FORMAT_JR        = 7'h8;
parameter R_FORMAT_MFHI      = 7'h10;
parameter R_FORMAT_MHLO      = 7'h12;
parameter R_FORMAT_SLL       = 7'h0;
parameter R_FORMAT_SLLV      = 7'h4;
parameter R_FORMAT_SLT       = 7'h2A;
parameter R_FORMAT_SRA       = 7'h3;
parameter R_FORMAT_SRAV      = 7'h7;
parameter R_FORMAT_SRL       = 7'h2;
parameter R_FORMAT_SUB       = 7'h22;
parameter R_FORMAT_BREAK     = 7'hD;
parameter R_FORMAT_RTE       = 7'h13;
parameter R_FORMAT_ADDM      = 7'h5;

// ----- OPCODE (I FORMAT INSTRUCTIONS) -----
parameter I_FORMAT_ADDI    = 7'h8;
parameter I_FORMAT_ADDIU   = 7'h9;
parameter I_FORMAT_BEQ     = 7'h4;
parameter I_FORMAT_BNE     = 7'h5;
parameter I_FORMAT_BLE     = 7'h6;
parameter I_FORMAT_BGT     = 7'h7;
parameter I_FORMAT_SLLM    = 7'h1;
parameter I_FORMAT_LB      = 7'h20;
parameter I_FORMAT_LH      = 7'h21;
parameter I_FORMAT_LUI     = 7'hF;
parameter I_FORMAT_LW      = 7'h23;
parameter I_FORMAT_SB      = 7'h28;
parameter I_FORMAT_SH      = 7'h29;
parameter I_FORMAT_SLTI    = 7'hA;
parameter I_FORMAT_SW      = 7'h2B;

// ----- OPCODE (J FORMAT INSTRUCTIONS) -----
parameter J_FORMAT_JUMP    = 7'h2;
parameter J_FORMAT_JAL     = 7'h3;

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;


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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

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
                        R_FORMAT_JR: begin
                            STATE = JR;
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
                        R_FORMAT_BREAK: begin
                            STATE = BREAK;
                        end
                        R_FORMAT_ADDM: begin
                            STATE = ADDM;
                        end
                    endcase
                end
                // I type
                I_FORMAT_ADDI: begin
                    STATE = ADDI;
                end
                I_FORMAT_SLTI: begin
                    STATE = SLTI;
                end
                I_FORMAT_LW: begin
                    STATE = LOAD_STORE_COMMON;
                end
                I_FORMAT_LH: begin
                    STATE = LOAD_STORE_COMMON;
                end
                I_FORMAT_LB: begin
                    STATE = LOAD_STORE_COMMON;
                end
                I_FORMAT_SW: begin
                    STATE = LOAD_STORE_COMMON;
                end
                I_FORMAT_SH: begin
                    STATE = LOAD_STORE_COMMON;
                end
                I_FORMAT_SB: begin
                    STATE = LOAD_STORE_COMMON;
                end
                I_FORMAT_BEQ: begin
                    STATE = BEQ;
                end
                I_FORMAT_BNE: begin
                    STATE = BNE;
                end
                I_FORMAT_BLE: begin
                    STATE = BLE;
                end
                I_FORMAT_BGT: begin
                    STATE = BGT;
                end
                I_FORMAT_LUI: begin
                    STATE = SHIFT_WITH_CTE;
                end
            endcase
        end
//
//
///////////////=-=-=-= R FORMAT INSTRUCTIONS   =-=-=-=///////////////
//
//

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd0; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == JR) begin
            PC_write            = 1'd1;
            PC_write_cond       = 1'd1;
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
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd0;
            PCSource            = 3'd5;

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
            shiftSourceControl  = 2'd1; //

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
            shiftSourceControl  = 2'd0; //

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

        else if(STATE == SHIFT_WITH_CTE) begin
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
            shamtControl        = 2'd1; //
            shiftSourceControl  = 2'd2; //

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            ShiftControl        = 3'd1; //
            PCSource            = 3'd0;

            STATE = LUI;
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
            shiftSourceControl  = 2'd1; //

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0; //

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
            shiftSourceControl  = 2'd0;
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
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd4; 
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd7; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == BREAK) begin
            PC_write            = 1'd1;
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
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; 
            ALUSourceB          = 3'd1; //
            AluOp               = 3'd2; // 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0; //

            STATE = ATRASA_PROX_INSTR;
        end

       else if(STATE == ADDM) begin  // carrega o endereço de rs na memoria
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0; //
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

            IorD                = 3'd4; //
            MemToReg            = 3'd0; 
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ADDM_STEP2;
        end

        else if(STATE == ADDM_STEP2) begin // espera o valor ser carregado
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

            IorD                = 3'd4;
            MemToReg            = 3'd0; 
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ADDM_STEP3;
        end

        else if(STATE == ADDM_STEP3) begin // carrega o valor da memoria no MDR
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0; 
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd1; //
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0; 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0; 
            shiftSourceControl  = 1'd0;

            IorD                = 3'd4;
            MemToReg            = 3'd0; 
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0; 

            STATE = ADDM_STEP4;
        end

        else if(STATE == ADDM_STEP4) begin // carrega rt na memoria
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0; //
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd1;

            RegDst              = 2'd0;
            ALUSourceA          = 2'd2;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0; 
            shiftSourceControl  = 1'd0;

            IorD                = 3'd5; //
            MemToReg            = 3'd0; 
            ALUSourceB          = 3'd2;
            AluOp               = 3'd1; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ADDM_STEP5;
        end

        else if(STATE == ADDM_STEP5) begin // espera o valor ser carregado
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd1;

            RegDst              = 2'd3;
            ALUSourceA          = 2'd2; 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0; 
            shiftSourceControl  = 1'd0;

            IorD                = 3'd5;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd2; 
            AluOp               = 3'd1; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0; 

            STATE = ADDM_STEP6;
        end

        else if(STATE == ADDM_STEP6) begin // faz a soma de mem[rt] + mem[rs]
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd3; //
            ALUSourceA          = 2'd2; 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0; 
            shiftSourceControl  = 1'd0;

            IorD                = 3'd5;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd2; 
            AluOp               = 3'd1; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0; 

            STATE = ADDM_STEP7;
        end

        else if(STATE == ADDM_STEP7) begin // salva o resultado no reg aluOut
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd1;

            RegDst              = 2'd3; //
            ALUSourceA          = 2'd2; 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0; 
            shiftSourceControl  = 1'd0;

            IorD                = 3'd5;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd2; 
            AluOp               = 3'd1; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0; 

            STATE = ADDM_FINAL;
        end

        else if(STATE == ADDM_FINAL) begin // salva o valor de aluOut no endereço destino
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd1; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd1;

            RegDst              = 2'd3; //
            ALUSourceA          = 2'd2; 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0; 
            shiftSourceControl  = 1'd0;

            IorD                = 3'd5;
            MemToReg            = 3'd0; //
            ALUSourceB          = 3'd2; 
            AluOp               = 3'd1; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0; 

            STATE = ATRASA_PROX_INSTR;
        end
//
//
///////////////=-=-=-= I FORMAT INSTRUCTIONS   =-=-=-=///////////////
//
//
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
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = END_IMMEDIATE;
        end

        else if(STATE == LOAD_STORE_COMMON) begin
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
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            // Adicionar um if/else depois
            if (opcode == I_FORMAT_LW || opcode == I_FORMAT_LH || opcode == I_FORMAT_LB) begin
                STATE = LOAD_BASIC_STEP;
            end
            else if (opcode == I_FORMAT_SW || opcode == I_FORMAT_SH || opcode == I_FORMAT_SB) begin
                STATE = STORE_BASIC_STEP;
            end
        end

        else if(STATE == LOAD_BASIC_STEP) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd6; //
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = LOAD_INTER_STEP;
        end

        else if(STATE == LOAD_INTER_STEP) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd6; //
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = LOAD_FINAL_STEP;
        end

        else if(STATE == LOAD_FINAL_STEP) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd1; //
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd6; //
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            if(opcode == I_FORMAT_LB) begin
                STATE = LB_FINAL;
            end
            else if(opcode == I_FORMAT_LH) begin
                STATE = LH_FINAL;
            end
            else if(opcode == I_FORMAT_LW) begin
                STATE = LW_FINAL;
            end
        end

        else if(STATE == LB_FINAL) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd1; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0; // 
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; 

            RegDst              = 2'd0; //
            ALUSourceA          = 2'd0; 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd2; //
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0; 
            MemToReg            = 3'd6; //
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == LH_FINAL) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd1; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0; // 
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; 

            RegDst              = 2'd0; //
            ALUSourceA          = 2'd0; 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd1; //
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0; 
            MemToReg            = 3'd6; //
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == LW_FINAL) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd1; //
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0; // 
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; 

            RegDst              = 2'd0; //
            ALUSourceA          = 2'd0; 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0; //
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0; 
            MemToReg            = 3'd6; //
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == STORE_BASIC_STEP) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0; //
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd6; //
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; //
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = STORE_INTER_STEP;
        end

         else if(STATE == STORE_INTER_STEP) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0; //
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; //

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd6; //
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; //
            AluOp               = 3'd1;
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = STORE_FINAL_STEP;
        end

        else if(STATE == STORE_FINAL_STEP) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0; // 
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd1; //
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0;

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1; // 
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd6; //
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3; // 
            AluOp               = 3'd1; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            if(opcode == I_FORMAT_SB) begin
                STATE = SB_FINAL;
            end
            else if(opcode == I_FORMAT_SH) begin
                STATE = SH_FINAL;
            end
            else if(opcode == I_FORMAT_SW) begin
                STATE = SW_FINAL;
            end
        end

        else if(STATE == SB_FINAL) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd1; //
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; 

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0; 
            storeControl        = 2'd2; //
            loadSizeControl     = 2'd0; 
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd6; 
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == SH_FINAL) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd1; //
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; 

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0; 
            storeControl        = 2'd1; //
            loadSizeControl     = 2'd0; 
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd6; 
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == SW_FINAL) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd1; //
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd0;
            B_write             = 1'd0;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd0; 

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0; 
            storeControl        = 2'd0; //
            loadSizeControl     = 2'd0; 
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd6; 
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == LUI) begin
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
            shamtControl        = 2'd1; // 
            shiftSourceControl  = 2'd2; //

            IorD                = 3'd0; 
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd2; //
            PCSource            = 3'd0;

            STATE = END_LUI;
        end

        else if(STATE == END_LUI) begin
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
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0; 
            MemToReg            = 3'd2; //
            ALUSourceB          = 3'd0; 
            AluOp               = 3'd0; 
            ShiftControl        = 3'd0;
            PCSource            = 3'd0;

            STATE = ATRASA_PROX_INSTR;
        end

        else if(STATE == BEQ) begin
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
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; 
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd2; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd1; //

            STATE = END_BEQ;
        end

        else if(STATE == END_BEQ) begin
            if (igual == 1'd1) begin
                PC_write            = 1'd0;
                PC_write_cond       = 1'd1; //
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
                shiftSourceControl  = 2'd0;

                IorD                = 3'd0;
                MemToReg            = 3'd0;
                ALUSourceB          = 3'd0;
                AluOp               = 3'd0;
                ShiftControl        = 3'd0;
                PCSource            = 3'd1;

                STATE = ATRASA_PROX_INSTR;
            end
            else if (igual == 1'd0) begin
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
                shiftSourceControl  = 2'd0;

                IorD                = 3'd0;
                MemToReg            = 3'd0;
                ALUSourceB          = 3'd0;
                AluOp               = 3'd0;
                ShiftControl        = 3'd0;
                PCSource            = 3'd0;

                STATE = ATRASA_PROX_INSTR;
            end
        end

        else if(STATE == BNE) begin
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
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; 
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd2; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd1; //

            STATE = END_BNE;
        end

        else if(STATE == END_BNE) begin
            if (igual == 1'd0) begin
                PC_write            = 1'd0;
                PC_write_cond       = 1'd1; //
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
                shiftSourceControl  = 2'd0;

                IorD                = 3'd0;
                MemToReg            = 3'd0;
                ALUSourceB          = 3'd0;
                AluOp               = 3'd0;
                ShiftControl        = 3'd0;
                PCSource            = 3'd1;

                STATE = ATRASA_PROX_INSTR;
            end
            else if (igual == 1'd1) begin
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
                shiftSourceControl  = 2'd0;

                IorD                = 3'd0;
                MemToReg            = 3'd0;
                ALUSourceB          = 3'd0;
                AluOp               = 3'd0;
                ShiftControl        = 3'd0;
                PCSource            = 3'd0;

                STATE = ATRASA_PROX_INSTR;
            end
        end

        else if(STATE == BLE) begin
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
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; 
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd2; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd1; //

            STATE = END_BLE;
        end

        else if(STATE == END_BLE) begin
            if (gt == 1'd0) begin
                PC_write            = 1'd0;
                PC_write_cond       = 1'd1; //
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
                shiftSourceControl  = 2'd0;

                IorD                = 3'd0;
                MemToReg            = 3'd0;
                ALUSourceB          = 3'd0;
                AluOp               = 3'd0;
                ShiftControl        = 3'd0;
                PCSource            = 3'd1;

                STATE = ATRASA_PROX_INSTR;
            end
            else if (gt == 1'd1) begin
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
                shiftSourceControl  = 2'd0;

                IorD                = 3'd0;
                MemToReg            = 3'd0;
                ALUSourceB          = 3'd0;
                AluOp               = 3'd0;
                ShiftControl        = 3'd0;
                PCSource            = 3'd0;

                STATE = ATRASA_PROX_INSTR;
            end
        end

        else if(STATE == BGT) begin
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
            ALUSourceA          = 2'd1; //
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 2'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0; 
            ALUSourceB          = 3'd0; //
            AluOp               = 3'd2; //
            ShiftControl        = 3'd0;
            PCSource            = 3'd1; //

            STATE = END_BGT;
        end

        else if(STATE == END_BGT) begin
            if (gt == 1'd1) begin
                PC_write            = 1'd0;
                PC_write_cond       = 1'd1; //
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
                shiftSourceControl  = 2'd0;

                IorD                = 3'd0;
                MemToReg            = 3'd0;
                ALUSourceB          = 3'd0;
                AluOp               = 3'd0;
                ShiftControl        = 3'd0;
                PCSource            = 3'd1;

                STATE = ATRASA_PROX_INSTR;
            end
            else if (gt == 1'd0) begin
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
                shiftSourceControl  = 2'd0;

                IorD                = 3'd0;
                MemToReg            = 3'd0;
                ALUSourceB          = 3'd0;
                AluOp               = 3'd0;
                ShiftControl        = 3'd0;
                PCSource            = 3'd0;

                STATE = ATRASA_PROX_INSTR;
            end
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
            shiftSourceControl  = 2'd0;

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
            shiftSourceControl  = 2'd0;

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