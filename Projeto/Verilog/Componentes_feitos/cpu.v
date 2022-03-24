module cpu (
    input wire clk,
    input wire reset
);

//Sinais da unidade de controle
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
    
    wire [2:0] ALU_control;
    wire [2:0] IorD;
    wire [1:0] RegDst;
    wire [2:0] MenToReg;
    wire [1:0] ALUSourceA;
    wire [2:0] ALUSourceB;
    wire [2:0] PCSource;

    wire Overflow;

//Data wires

    wire [31:0] PC_out;
    wire [31:0] MEM_out;
    wire [31:0] RegA_out;
    wire [31:0] RegB_out;
    wire [31:0] ALUOut_out;
    wire [31:0] MDR_out;
    //wire [??:0] LS_out;    ***LS_OUT pode ter varios tamanhos, n sei como faz os bits pra ele*** (e ainda falta fazer o LOAD SIZE)
    wire [31:0] REGS_out1;
    wire [31:0] REGS_out2;
    wire [31:0] SL2_out;
    wire [31:0] SE16_32_out;
    wire [31:0] SE1_32_out
    wire [31:0] EPC_out;
    wire mux_branch_out;
    wire zero_not_out;
    wire GT_not_out;

    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET;

    wire [31:0] ALU_result;
	wire Negativo;
    wire zero;
    wire LT;
    wire GT;
    wire Igual;



//mux _out

    wire [31:0] mux_IorD_out;
    wire [31:0] mux_PCSource_out;
    wire [31:0] mux_regDst_out;   //talvez n seja 32 bits, vai depender do que o "registers" recebe como regDst
    wire [31:0] mux_MemToReg_out;
    wire [31:0] mux_aluA_out;
    wire [31:0] mux_aluB_out;

    Registrador PC_ (
        clk,
        reset,
        PC_write,
        mux_PCSource_out,
        PC_out

    );

    mux_mem M_MEM_ (
        IorD,
        PC_out,
        RegA_out,
        RegB_out,
        ALUOut_out,
        mux_IorD_out

    );

    Memoria MEM_ (
        mux_IorD_out,
        clk,
        MEMRead,     // 0 = LER || 1 = ESCREVER
        //SC_out,
        MEM_out
    );

    /*store_control SC_ (
        selector,
        data_B,
        data_data,
        SC_out
    )*/

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

    sign_extend_16_32 SE16_32_ (
        OFFSET,
        SE16_32_out
    );

    sign_extend_1_32 SE1_32_ (
        LT,
        SE1_32_out
    );

    /*RegDesloc shift_left2 (   //ver como usa o RegDesloc (ta nos componentes dados)
        ???????
        ???????
        ???????
        ???????
        SL2_out
    );*/

    Registrador MDR_ (
        clk,
        reset,
        MDR_load, // sinal da unidade de controle para MDR (no diagrama que fizemos nao botamos esse sinal)
        MEM_out,
        MDR_out
    );

    load_size LS_ ( // precisamos criar um load_size que faça as coisas que a gente considerou que ele faz
        ????
        ????
        ????
        LS_out
    );

    mux_regDst M_DST_ (
        RegDst,
        RT,
        OFFSET, 
        mux_regDst_out;
    );

    mux_regData M_RDATA_ (
        MenToReg,
        ALUOut_out,
        //HI_out,
        //Shift_Reg_out,
        SE1_32_out,
        //LO_out,
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

    mux_ulaA M_A_ (
        ALUSourceA,
        PC_out,
        RegA_out,
        MDR_out,     // o diagrama ta tao confuso que n tenho ctza se a entrada 2 vem do MDR ou nao
        mux_aluA_out 
    );

    mux_ulaB M_B_ (
        ALUSourceB,
        RegB_out,
        MEM_out,
        SE16_32_out,
        SL2_out,
        MDR_out,     // o diagrama ta tao confuso que n tenho ctza se a entrada 2 vem do MDR ou nao 
        mux_aluB_out 
    );

    ula32 ALU_ (
        mux_aluA_out, 				//-- Operando A da ULA
		mux_aluB_out 				//-- Operando B da ULA
		ALU_control 		        //-- Seletor da opera��o da ULA
		ALU_result 				    //-- Resultado da opera��o (SOMA, SUB, AND, NOT, INCREMENTO, XOR)  
		Overflow 				    //-- Sinaliza overflow aritm�tico
		Negativo  //NAO USAMOS	    //-- Sinaliza valor negativo
		zero 						//-- Sinaliza quando S for zero
		Igual	//NAO USAMOS		  -- Sinaliza se A=B
		GT							//-- Sinaliza se A>B
		LT							//-- Sinaliza se A<B
    );

    ALU_control ALUCTRL_(
        //input  wire    [1:0]   selector,
        //input  wire    [2:0]   ALU_op,
        //input  wire    [5:0]   funct,
        //output wire    [2:0]   data_out

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

    mux_pcSource M_PCS_ (
        PCSource,
        ALU_result,
        ALUOut_out,
        EPC_out,
        Data_3,     //mudar o nome   *** entrada da concatenacao de PC com os bits de JUMP, tem que ver como funciona isso ***
        //LS_OUT,    ------ precisa fazer o LOADSIZE ainda
        RegA_out, 
        mux_PCSource_out 

    );

    not ZNOT_ (
        zero,
        zero_not_out
    );

    not GTNOT_ (
        GT,
        GT_not_out
    );

    mux_aluLogic M_BRANCH_ (
        ALULogic,
        zero,
        zero_not_out,
        GT,
        GT_not_out,
        mux_branch_out
    );


    // DIV E SHAMT

    /*mux_shamtControl M_SC_ (
        nput  wire     [1:0]   selector,
        input  wire    [10:0]  Data_0,    --shamt[10:6]
        input  wire    [31:0]  Data_2,    
        input  wire    [31:0]  Data_3,    --B
        output wire    [31:0]  Data_out 

    );*/

    Registrador SHIFT_REG_ ( // É Registrador? mas tem 2 entradas entao deu ruim pq n é igual ao registrador fornecido


    );



endmodule