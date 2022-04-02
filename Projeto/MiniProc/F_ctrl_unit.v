module F_ctrl_unit (
    input wire clk,
    input wire reset,
    input wire Of,
    input wire Ng,
    input wire Zr,
    input wire Eq,
    input wire Gt,
    input wire Lt,
    input wire [5:0] OPCODE,

    output reg PC_w,
    output reg MEM_w,
    output reg IR_w,
    output reg RB_w,
    output reg AB_w,
    output reg [2:0] ULA_c,
    output reg M_WREG,
    output reg M_ULAA,
    output reg [1:0] M_ULAB,
    output reg rst_out
);

reg [1:0] STATE;
reg [2:0] COUNTER;

    parameter ST_COMMON = 2'b00;
    parameter ST_ADD    = 2'b01;
    parameter ST_ADDI   = 2'b10;
    parameter ST_RESET  = 2'b11;

    parameter ADD       = 6'b000000;
    parameter ADDI      = 6'b001000;
    parameter RESET     = 6'b111111;

initial begin
    rst_out = 1'b1;
end

always @(posedge clk) begin
    if (reset == 1'b1) begin
        if (STATE != ST_RESET) begin
            STATE = ST_RESET;

            PC_w,   = 1'b0;
            MEM_w   = 1'b0;
            IR_w    = 1'b0;
            RB_w    = 1'b0;
            AB_w    = 1'b0;
            ULA_c   = 3'b000;
            M_WREG  = 1'b0;
            M_ULAA  = 1'b0;
            M_ULAB  = 2'b00;
            rst_out = 1'b1;

            COUNTER = 3'b000;
        end
        else begin
             STATE = ST_COMMON;

            PC_w,   = 1'b0;
            MEM_w   = 1'b0;
            IR_w    = 1'b0;
            RB_w    = 1'b0;
            AB_w    = 1'b0;
            ULA_c   = 3'b000;
            M_WREG  = 1'b0;
            M_ULAA  = 1'b0;
            M_ULAB  = 2'b00;
            rst_out = 1'b0;

            COUNTER = 3'b000;
        end
    end
    else begin
        case (STATE)
            ST_COMMON: begin
                if (COUNTER == 3'b000 || COUNTER = 3'b010) begin
                    STATE = ST_COMMON;

                    PC_w,   = 1'b0;
                    MEM_w   = 1'b0;
                    IR_w    = 1'b0;
                    RB_w    = 1'b0;
                    AB_w    = 1'b0;
                    ULA_c   = 3'b001;
                    M_WREG  = 1'b0;
                    M_ULAA  = 1'b0;
                    M_ULAB  = 2'b01;
                    rst_out = 1'b0;

                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b011) begin
                    STATE = ST_COMMON;

                    PC_w,   = 1'b1;
                    MEM_w   = 1'b0;
                    IR_w    = 1'b1;
                    RB_w    = 1'b0;
                    AB_w    = 1'b0;
                    ULA_c   = 3'b001;
                    M_WREG  = 1'b0;
                    M_ULAA  = 1'b0;
                    M_ULAB  = 2'b01;
                    rst_out = 1'b0;

                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b100) begin
                    STATE = ST_COMMON;

                    PC_w,   = 1'b0;
                    MEM_w   = 1'b0;
                    IR_w    = 1'b0;
                    RB_w    = 1'b0;
                    AB_w    = 1'b1;
                    ULA_c   = 3'b000;
                    M_WREG  = 1'b0;
                    M_ULAA  = 1'b0;
                    M_ULAB  = 2'b00;
                    rst_out = 1'b0;

                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b101) begin
                    case (OPCODE)
                        ADD: begin
                            STATE = ST_ADD;
                        end
                        ADDI: begin
                            STATE = ST_ADDI;
                        end
                        RESET: begin
                            STATE = ST_RESET;
                        end
                    endcase
                    PC_w,   = 1'b0;
                    MEM_w   = 1'b0;
                    IR_w    = 1'b0;
                    RB_w    = 1'b0;
                    AB_w    = 1'b0;
                    ULA_c   = 3'b000;
                    M_WREG  = 1'b0;
                    M_ULAA  = 1'b0;
                    M_ULAB  = 2'b00;
                    rst_out = 1'b0;

                    COUNTER = 3'b000;
                end
            end
            ST_ADD: begin
                if (COUNTER == 3'b000) begin
                    STATE = ST_ADD;

                    PC_w,   = 1'b0;
                    MEM_w   = 1'b0;
                    IR_w    = 1'b0;
                    RB_w    = 1'b1;
                    AB_w    = 1'b0;
                    ULA_c   = 3'b001;
                    M_WREG  = 1'b1;
                    M_ULAA  = 1'b1;
                    M_ULAB  = 2'b00;
                    rst_out = 1'b0;

                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b001) begin
                    
                    STATE = ST_COMMON;

                    PC_w,   = 1'b0;
                    MEM_w   = 1'b0;
                    IR_w    = 1'b0;
                    RB_w    = 1'b1;
                    AB_w    = 1'b0;
                    ULA_c   = 3'b001;
                    M_WREG  = 1'b1;
                    M_ULAA  = 1'b1;
                    M_ULAB  = 2'b00;
                    rst_out = 1'b0;

                    COUNTER = 3'b000;
                
                end
            end
            ST_ADDI: begin
                if (COUNTER == 3'b000) begin
                    STATE = ST_ADDI;

                    PC_w,   = 1'b0;
                    MEM_w   = 1'b0;
                    IR_w    = 1'b0;
                    RB_w    = 1'b1;
                    AB_w    = 1'b0;
                    ULA_c   = 3'b001;
                    M_WREG  = 1'b0;
                    M_ULAA  = 1'b1;
                    M_ULAB  = 2'b10;
                    rst_out = 1'b0;

                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b001) begin
                    
                    STATE = ST_COMMON;

                    PC_w,   = 1'b0;
                    MEM_w   = 1'b0;
                    IR_w    = 1'b0;
                    RB_w    = 1'b1;
                    AB_w    = 1'b0;
                    ULA_c   = 3'b001;
                    M_WREG  = 1'b0;
                    M_ULAA  = 1'b1;
                    M_ULAB  = 2'b10;
                    rst_out = 1'b0;

                    COUNTER = 3'b000;
                
                end
            end
            ST_RESET: begin
                if (COUNTER == 3'b000) begin
                    STATE = ST_RESET;

                    PC_w,   = 1'b0;
                    MEM_w   = 1'b0;
                    IR_w    = 1'b0;
                    RB_w    = 1'b0;
                    AB_w    = 1'b0;
                    ULA_c   = 3'b000;
                    M_WREG  = 1'b0;
                    M_ULAA  = 1'b0;
                    M_ULAB  = 2'b00;
                    rst_out = 1'b1;

                    COUNTER = 3'b000;
                end
            end
        endcase
    end
end

endmodule