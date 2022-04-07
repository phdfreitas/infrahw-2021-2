module F_cpu (
    input wire clk,
    input wire reset
);

// =-=-=-=-= Sinais da unidade de controle =-=-=-=-=
    // =-=-=-=-= UNITÁRIOS =-=-=-=-= 
    wire PC_write;
    wire PC_write_cond;
    wire MEMRead;
    wire IRWrite;
    wire MDRWrite;
    wire RegWrite;
    wire A_Write; 
    wire B_Write; 
    wire AluOutWrite;
    wire EPCWrite;
    wire shiftSource_control;

    // =-=-=-= EXCEPTIONS =-=-=-= // 
    wire Overflow;

    // =-=-=-=-= DOIS DÍGITOS =-=-=-=-=
    wire [1:0] RegDst;
    wire [1:0] ALUSourceA;
    wire [1:0] store_control_sign;
    wire [1:0] load_size_control;
    wire [1:0] shamt_control;

    // =-=-=-=-= TRÊS DÍGITOS =-=-=-=-=
    wire [2:0] IorD;
    wire [2:0] MemToReg;
    wire [2:0] AluOp;
    wire [2:0] ALU_control;
    wire [2:0] ALUSourceB;
    wire [2:0] ShiftControl;
    wire [2:0] PCSource;
    
// =-=-=-=-= Sinais da unidade de controle End =-=-=-=-=

// =-=-=-=-= Data wires Start =-=-=-=-=
    wire [31:0] PC_out;
    wire [31:0] MEM_out;
    wire [31:0] RegA_out;
    wire [31:0] RegB_out;
    wire [31:0] ALUOut_out;
    wire [31:0] MDR_out;
    wire [31:0] LS_out;
    wire [31:0] REGS_out1;
    wire [31:0] REGS_out2;
    wire [31:0] SL2_out;
    wire [31:0] SE16_32_out;
    wire [31:0] SE1_32_out;
    wire [31:0] EPC_out;
    wire [31:0] SC_out;
    wire [31:0] Shift_Reg_out;
    wire [31:0] shiftSource_out;
    wire [31:0] HI_out      = 32'd0;
    wire [31:0] LO_out      = 32'd0;
    wire [31:0] mux_IorD_out;
    wire [31:0] mux_PCSource_out;
    wire [31:0] mux_MemToReg_out;
    wire [31:0] mux_aluA_out;
    wire [31:0] mux_aluB_out;
    wire [4:0]  mux_regDst_out;

    // INSTRUCTIONS
    wire [15:0]     OFFSET;
    wire [5:0]      FUNCT       = OFFSET[5:0];
    wire [5:0]      OPCODE;
    wire [4:0]      RS;
    wire [4:0]      RT;
    wire [4:0]      RD          = OFFSET[15:11];

    // SHAMT CONTROL
    wire [4:0]  SHAMT           = OFFSET[10:6];
    wire [4:0]  Shamt_Memory    = MDR_out[4:0];
    wire [4:0]  Shamt_B         = RegB_out[4:0];
    wire [4:0]  Shamt_Out;       

    // STACK STUFF
    wire [4:0] TW_NINE          = 5'd29;
    wire [4:0] TH_ONE           = 5'd31;
    
    // EXCEPTIONS AND CONSTANTS
    wire [31:0] OPCODE_INEXISTENTE  = 32'd253;
    wire [31:0] OVERFLOW_EXP        = 32'd254;
    wire [31:0] DIV_ZERO_EXP        = 32'd255;
    wire [31:0] STACK_START         = 32'd227;
    wire [31:0] Data1_Four          = 32'd4;   // ALUSourceB Mux Data_1
    wire [4:0]  Data1_Sixteen       = 5'd16;   // ShamtControl Mux Data_1
    
    // JUMP INSTRUCTION
    wire [27:0] extend_26_28_out;
    wire [31:0] extend_28_32_out;

    // ALU RESULT AND FLAGS
    wire [31:0] ALU_result;
	wire Negativo;
    wire zero;
    wire LT;
    wire GT;
    wire Igual;

    wire PC_w;
// =-=-=-=-= Data wires End =-=-=-=-=

    Registrador PC_ (
        clk,
        reset,
        PC_w,
        mux_PCSource_out,
        PC_out
    );

    F_mux_mem M_MEM_ (
        IorD,
        PC_out,
        OPCODE_INEXISTENTE,
        OVERFLOW_EXP,
        DIV_ZERO_EXP,
        RegA_out,
        RegB_out,
        ALUOut_out,
        mux_IorD_out
    );

    Memoria MEM_ (
        mux_IorD_out,
        clk,
        MEMRead,     // 0 = LER || 1 = ESCREVER
        SC_out,
        MEM_out
    );

    F_store_control SC_ (
        store_control_sign,
        RegB_out,
        MDR_out,
        SC_out
    );

    Instr_Reg IR_ (
        clk,
        reset,
        IRWrite,
        MEM_out,
        OPCODE,
        RS,
        RT,
        OFFSET
    );

    F_sign_extend_16_32 SE16_32_ (
        OFFSET,
        SE16_32_out
    );

    F_sign_extend_1_32 SE1_32_ (
        LT,
        SE1_32_out
    );

    F_shift_left_2 Shift_Left2_ (
        SE16_32_out,
		SL2_out
    );

    Registrador MDR_ (
        clk,
        reset,
        MDRWrite,
        MEM_out,
        MDR_out
    );

    F_load_size LS_ (
        load_size_control,
        MDR_out,
        LS_out
    );

    F_mux_shiftSource shiftSource_ (
        shiftSource_control,
        RegA_out,
        RegB_out,
        shiftSource_out
    );

    F_mux_shamtControl shamtSource_ (
        shamt_control,
        SHAMT,
        Data1_Sixteen,
        Shamt_Memory,
        Shamt_B,
        Shamt_Out
    );

    RegDesloc Shift_Reg_ (
        clk,
        reset,
        ShiftControl,
        Shamt_Out,		
        shiftSource_out,
        Shift_Reg_out
    );

    F_mux_regDst M_DST_ ( 
        RegDst,           
        RT,
        TW_NINE,
        TH_ONE,                
        RD, 
        mux_regDst_out
    );

    F_mux_regData M_RDATA_ (
        MemToReg,
        ALUOut_out,
        HI_out,
        Shift_Reg_out,
        STACK_START,
        SE1_32_out,
        LO_out,
        LS_out,
        mux_MemToReg_out
    );

    Banco_reg REGS_ (
        clk,
		reset,
		RegWrite,
		RS,
		RT,
		mux_regDst_out,
	    mux_MemToReg_out,
		REGS_out1,
		REGS_out2
    );

    Registrador A_ (
        clk,
        reset,
        A_Write,
        REGS_out1,
        RegA_out
    );

    Registrador B_ (
        clk,
        reset,
        B_Write,
        REGS_out2,
        RegB_out
    );

    F_mux_ulaA M_A_ (
        ALUSourceA,
        PC_out,
        RegA_out,
        MDR_out,
        mux_aluA_out 
    );

    F_mux_ulaB M_B_ (
        ALUSourceB,
        RegB_out,
        Data1_Four, 
        MEM_out,
        SE16_32_out,
        SL2_out,
        MDR_out,  
        mux_aluB_out 
    );

    ula32 ALU_ (
        mux_aluA_out, 				
		mux_aluB_out, 				
		AluOp, 		        
		ALU_result, 				  
		Overflow, 				    
		Negativo,  //NAO USAMOS	    
		zero, 						
		Igual,	//NAO USAMOS		
		GT,							
		LT
    );

    Registrador ALUOut_ (
        clk,
        reset,
        AluOutWrite,
        ALU_result,
        ALUOut_out
    );

    Registrador EPC_ (
        clk,
        reset,
        EPCWrite,
        ALUOut_out,
        EPC_out
    );

    F_extend_26_28 EX_26_to_28_ (
        RS, 
        RT,
        OFFSET,

        extend_26_28_out
    );

    F_extend_28_32 EX_28_to_32_ (
        PC_out, 
        extend_26_28_out,

        extend_28_32_out
    );

    F_mux_pcSource M_PCS_ (
        PCSource,
        ALU_result,
        ALUOut_out,
        EPC_out,
        extend_28_32_out,
        LS_out,
        RegA_out, 

        mux_PCSource_out 

    );

    F_orgate OR_ (
       PC_write_cond,  // saida do and
       PC_write,     // sinal da un de controle
       PC_w        // pc_write real (nao o da un de controle)
    );

    F_ctrl_unit CONTROL_ (
        clk,
        reset,
    
        Overflow,
        Negativo,
	    zero,
	    Igual,
	    GT,
	    LT,
    
        OPCODE,
        FUNCT,
    
    // Sinais de controle unitários //
/**/    PC_write,                   // =-=-=-=-= Não Mudar sem Testar as instruções que estão funcionando =-=-=-=-=
        PC_write_cond,
        MEMRead,
        IRWrite,
        RegWrite,
        A_Write,
        B_Write,
        MDRWrite,
        EPCWrite,
        AluOutWrite,

    // Sinais de controle dois dígitos
        RegDst,
        ALUSourceA,
        store_control_sign,
        load_size_control,
        shamt_control,
        shiftSource_control,

    // Controles de três dígitos
        IorD,
        MemToReg,
        ALUSourceB,
        AluOp,
        ShiftControl,
        PCSource
    );
endmodule