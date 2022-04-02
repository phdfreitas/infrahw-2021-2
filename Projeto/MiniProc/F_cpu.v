module F_cpu (
    input wire clk,
    input wire reset,

);

 // Flags

    wire Of;
    wire Ng;
    wire Zr;
    wire Eq;
    wire Gt;
    wire Lt;

 //control wires
    wire PC_w;
    wire MEM_w;
    wire IR_w;
    wire M_WREG;
    wire RB_w;
    wire AB_r;
    wire M_ULAA;
    wire M_ULAB;

    //Data wires

    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET;
    wire [4:0] WRITEREG_in;

    wire [31:0] ULA_out;
    wire [31:0] PC_out;
    wire [31:0] MEM_to_IR;
    wire [31:0] RB_to_A;
    wire [31:0] RB_to_B;
    wire [31:0] A_out;
    wire [31:0] B_out;
    wire [31:0] SE_out;
    wire [31:0] ULAA_out;
    wire [31:0] ULAB_out;



    Registrador PC_ (
        clk,
        reset,
        PC_w,
        ULA_out,
        PC_out
    );

    Memoria MEM_ (
        PC_out,
        clk,
        MEM_w,
        ULA_out,
        MEM_to_IR
    );

    Instr_Reg IR_ (
        clk,
        reset,
        IR_w,
        MEM_to_IR,
        OPCODE,
        RS,
        RT,
        OFFSET
    );
    
    F_mux_writeReg M_WREG_ (
        M_WREG,
        RT,
        OFFSET,
        WRITEREG_in
    );

    Banco_reg REG_BASE_(
        clk,
        reset,
        RB_w,
        RS,
        RT,
        WRITEREG_in,
        ULA_out,
        RB_to_A,
        RB_to_B
    );

    Registrador A_ (
        clk,
        reset,
        AB_r,
        RB_to_A,
        A_out
    );

    Registrador B_ (
        clk,
        reset,
        AB_r,
        RB_to_B,
        B_out
    );

    F_sign_extend_16 SE_ (
        OFFSET,
        SE_out
    );

    F_mux_ulaA M_ULAA_ (
        M_ULAA,
        PC_out,
        A_out,
        ULAA_out
    );

    F_mux_ulaB M_ULAB_ (
        M_ULAB,
        B_out,
        SE_out,
        ULAB_out
    );

    ula32 ULA_ (
        ULAA_out,
        ULAB_out,
        ULA_c,
        ULA_out,
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt
    );

    ctrl_unit CTRL_ (
        clk,
        reset,
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt,
        OPCODE,
        PC_w,
        MEM_w,
        IR_w,
        RB_w,
        AB_w,
        ULA_c,
        M_WREG,
        M_ULAA,
        M_ULAB,
        reset
    );

    endmodule