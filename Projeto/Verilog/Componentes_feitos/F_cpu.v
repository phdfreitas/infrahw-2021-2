module F_cpu (
    input wire clk,
    input wire reset
);

// =-=-=-=-= Sinais da unidade de controle Start =-=-=-=-=
    wire PC_write;
    wire MEMRead;     // 0 = LER || 1 = ESCREVER
    wire IRWrite;
    wire MDR_load;
    wire RegWrite;
    wire B_load;
    wire A_load;
    wire AluOutWrite;
    wire EPCWrite;
    wire ALULogic;

    wire [2:0] AluOp;
    
    wire [2:0] ALU_control;
    wire [2:0] IorD;
    wire [1:0] RegDst;
    wire [2:0] MemToReg;
    wire [1:0] ALUSourceA;
    wire [2:0] ALUSourceB;
    wire [2:0] PCSource;
    wire [1:0] store_control_sign;
    wire [1:0] load_size_control;

    wire [1:0] shamt_control;
    wire [1:0] shiftSource_control;
    
    wire Overflow;
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
    wire mux_branch_out;
    wire zero_not_out;
    wire GT_not_out;

    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET;
    wire [5:0]  FUNCT = OFFSET[5:0];

    wire [31:0] OPCODE_INEXISTENTE;
    wire [31:0] OVERFLOW_EXP;
    wire [31:0] DIV_ZERO_EXP;

    wire [31:0] STACK_START;
    wire [31:0] HI_out;
    wire [31:0] LO_out;

    wire [31:0] PC_PLUS_FOUR;

    wire [27:0] extend_26_28_out;
    wire [31:0] extend_28_32_out;

    wire [31:0] ALU_result;
	wire Negativo;
    wire zero;
    wire LT;
    wire GT;
    wire Igual;

    wire reset_out;
// =-=-=-=-= Data wires End =-=-=-=-=


// =-=-=-=-= mux _out start =-=-=-=-=
    wire [31:0] mux_IorD_out;
    wire [31:0] mux_PCSource_out;
    wire [31:0] mux_regDst_out;   //talvez n seja 32 bits, vai depender do que o "registers" recebe como regDst
    wire [31:0] mux_MemToReg_out;
    wire [31:0] mux_aluA_out;
    wire [31:0] mux_aluB_out;
// =-=-=-=-= mux _out end =-=-=-=-=

    Registrador PC_ (
        clk,
        reset,
        PC_write,
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
        RegB_out,        // Menos significativos
        MDR_out,
        store_control_sign,
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

    RegDesloc shift_left2_offset (
        Clk,
		Reset,
		3'b010,
		5'b00010,
		SE16_32_out,
		SL2_out
    );

    Registrador MDR_ (
        clk,
        reset,
        MDR_load,
        MEM_out,
        MDR_out
    );

    F_load_size LS_ (
        load_size_control,
        MDR_out,
        LS_out
    );

    /*mux_regDst M_DST_ ( // Precisa adicionar um "F_" antes do nome
        RegDst,           // o módulo desse mux tá sem padrão algum
        RT,               // não corrigi pq não entendi direito. 
        OFFSET, 
        mux_regDst_out
    );*/

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
        Clk,
		Reset,
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
        A_load,      // sinal da unidade de controle para A (no diagrama que fizemos nao botamos esse sinal)
        REGS_out1,
        RegA_out
    );

    Registrador B_ (
        clk,
        reset,
        B_load,      // sinal da unidade de controle para B (no diagrama que fizemos nao botamos esse sinal)
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
        PC_PLUS_FOUR,
        MEM_out,
        SE16_32_out,
        SL2_out,
        MDR_out,  
        mux_aluB_out 
    );

    ula32 ALU_ (
        mux_aluA_out, 				//-- Operando A da ULA
		mux_aluB_out, 				//-- Operando B da ULA
		ALU_control, 		        //-- Seletor da opera��o da ULA
		ALU_result, 				    //-- Resultado da opera��o (SOMA, SUB, AND, NOT, INCREMENTO, XOR)  
		Overflow, 				    //-- Sinaliza overflow aritm�tico
		Negativo,  //NAO USAMOS	    //-- Sinaliza valor negativo
		zero, 						//-- Sinaliza quando S for zero
		Igual,	//NAO USAMOS		  -- Sinaliza se A=B
		GT,							//-- Sinaliza se A>B
		LT							//-- Sinaliza se A<B
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

    F_not ZNOT_ (
        zero,
        zero_not_out
    );

    F_not GTNOT_ (
        GT,
        GT_not_out
    );

    F_mux_aluLogic M_BRANCH_ (
        ALULogic,
        zero,
        zero_not_out,
        GT,
        GT_not_out,
        mux_branch_out
    );

    F_ctrl_unit CONTROL_ (
        clk,
        reset,
        
        Overflow, 				    //-- Sinaliza overflow aritm�tico
		Negativo,  //NAO USAMOS	    //-- Sinaliza valor negativo
		zero, 						//-- Sinaliza quando S for zero
		Igual,	//NAO USAMOS		  -- Sinaliza se A=B
		GT,							//-- Sinaliza se A>B
		LT,							//-- Sinaliza se A<B

        OPCODE,
        FUNCT,
    // =-=-=-=-=-=-=-=-=-=-=-= //

    // Sinais de controle unitários //
        PC_write,
        MEMRead,
        IRWrite,
        RegWrite,
        A_load, // Depois mudar o nome pra A_write e embaixo pra B_write
        B_load,

    // Controladores dos mux (da esquerda para a direita)
        IorD,
        RegDst,
        MemToReg,
        ALUSourceA,
        ALUSourceB,
        PCSource,

        AluOp,
        AluOutWrite,

        reset_out
    );

    /* Amanhã vou fazer o shamtControl, o shiftSource e o ShiftReg
    F_mux_shamtControl M_ShamtC_ (
        
    );

    F_mux_shiftSourceControl M_ShiftC_ (
        
    );

    RegDesloc SHIFT_REG_ ( // É Registrador? mas tem 2 entradas entao deu ruim pq n é igual ao registrador fornecido

    );*/
endmodule