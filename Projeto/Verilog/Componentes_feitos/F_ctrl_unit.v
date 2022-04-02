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
parameter WAIT_AUX          = 6'd3;
parameter DECODE            = 6'd4;
parameter ADD               = 6'd5;
parameter SUB               = 6'd6;
parameter ADDI              = 6'd7;
parameter END_R             = 6'd8;
parameter END_IMMEDIATE     = 6'd9;


initial begin
    STATE = INSTRUCTION_FETCH;
end

always @(posedge clk) begin
    if (reset) begin
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

            RegDst              = 2'd1;
            ALUSourceA          = 2'd0;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            PCSource            = 3'd0;

            STATE = INSTRUCTION_FETCH;
    end
    else begin
        if(STATE == INSTRUCTION_FETCH) begin
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
            ALUSourceA          = 2'd0;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd1;
            AluOp               = 3'd1;
            PCSource            = 3'd0;

            STATE = WAIT;
        end
    
        else if(STATE == WAIT) begin
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
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            PCSource            = 3'd0;

            STATE = WAIT_AUX;
        end

        else if(STATE == WAIT_AUX) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd1;
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
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd0;
            PCSource            = 3'd0;

            STATE = DECODE;
        end

        else if(STATE == DECODE) begin
            PC_write            = 1'd0;
            PC_write_cond       = 1'd0;
            MEMRead             = 1'd0;
            IRWrite             = 1'd0;
            RegWrite            = 1'd0;
            A_write             = 1'd1;
            B_write             = 1'd1;
            MDR_load            = 1'd0;
            EPCWrite            = 1'd0;
            AluOutWrite         = 1'd1;

            RegDst              = 2'd0;
            ALUSourceA          = 2'd0;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd3;
            ALUSourceB          = 3'd4;
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
                    endcase
                end

                6'h8: begin
                    STATE = ADDI;
                end

                // Fazer opCodes do tipo I
                // Fazer opCodes do tipo J 
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
            AluOutWrite         = 1'd1;

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd0;
            AluOp               = 3'd1;
            PCSource            = 3'd0;

            STATE = END_R;
        end

        else if(STATE == END_R) begin
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
            AluOutWrite         = 1'd1;

            RegDst              = 2'd0;
            ALUSourceA          = 2'd1;
            storeControl        = 2'd0;
            loadSizeControl     = 2'd0;
            shamtControl        = 2'd0;
            shiftSourceControl  = 1'd0;

            IorD                = 3'd0;
            MemToReg            = 3'd0;
            ALUSourceB          = 3'd3;
            AluOp               = 3'd1;
            PCSource            = 3'd0;

            STATE = END_IMMEDIATE;
        end

        else if(STATE == END_IMMEDIATE) begin
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