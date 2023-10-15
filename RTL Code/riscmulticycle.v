module riscmulticycle(
	input  clk, rst_n, core_select,
	output  MemWrite,
	output   [31:0] Adr, WriteData,
	input   [31:0] ReadData,
	output   [1:0]Mem_Data_length,
	output   MemRead,MemEn);

	wire RegWrite, jump;
	wire [1:0] ResultSrc;
	wire [2:0] ImmSrc; // expand to 3-bits for lui and auipc
	wire [3:0] ALUControl;
	wire PCWrite;
	wire IRWrite;
	wire [1:0] ALUSrcA;
	wire [1:0] ALUSrcB;
	wire AdrSrc;
	wire [3:0] Flags; // added for other branches
	wire [6:0] op;
	wire [2:0] funct3;
	wire funct7b5;
	wire LoadType; // added for lbu
	wire StoreType; // added for sb
	wire PCTargetSrc; // added for jalr
	controller c(
		clk, 
		rst_n,
		core_select, 
		op, 
		funct3, 
		funct7b5, 
		Flags,
		ImmSrc, 
		ALUSrcA, 
		ALUSrcB,
		ResultSrc, 
		AdrSrc, 
		ALUControl,
		IRWrite, 
		PCWrite, 
		RegWrite, 
		MemWrite,
		LoadType, 
		StoreType, // lbu, sb
		PCTargetSrc,
		Mem_Data_length, // jalr
		MemRead,MemEn); 


	datapath dp(
		clk, 
		rst_n,
		ImmSrc, 
		ALUSrcA, 
		ALUSrcB,
		ResultSrc, 
		AdrSrc, 
		IRWrite, 
		PCWrite,
		RegWrite, 
		MemWrite, 
		ALUControl,
		LoadType, 
		StoreType, 
		PCTargetSrc,
		op, 
		funct3,
		funct7b5, 
		Flags, 
		Adr, 
		ReadData, 
		WriteData);
endmodule
