module controller(
	input clk,
	input   rst_n,
	input core_select, 
	input   [6:0] op,
	input   [2:0] funct3,
	input   funct7b5,
	input   [3:0] Flags,

	
	output   [2:0] ImmSrc,
	output   [1:0] ALUSrcA, ALUSrcB,
	output   [1:0] ResultSrc,
	output   AdrSrc,
	output   [3:0] ALUControl,
	output   IRWrite, PCWrite,
	output   RegWrite, MemWrite,
	output   LoadType,
	output   StoreType,
	output   PCTargetSrc,
	output   [1:0] Mem_Data_length,
	output   MemRead,MemEn);


	 wire [1:0] ALUOp;
	 wire Branch, PCUpdate;
	 wire branchtaken;
	 wire is_core_posedge; 

	mainfsm fsm(
		clk, 
		rst_n, 
		op,
		is_core_posedge, 
		ALUSrcA, 
		ALUSrcB, 
		ResultSrc, 
		AdrSrc,
		IRWrite, 
		PCUpdate, 
		RegWrite, 
		MemWrite,
		ALUOp, 
		Branch,
		MemRead, MemEn);
		
        assign MemEn=MemWrite | MemRead| 1'b1;
	aludecoder ad(
		op[5], 
		funct3, 
		funct7b5, 
		ALUOp, 
		ALUControl);
		
	posedge_detect core_posedge(
		.clk(clk), 
		.reset_n(rst_n), 
		.sclk(core_select), 
		.is_posedge(is_core_posedge)
		); 

	instructiondecoder id(
		op, 
		ImmSrc);
		
       mux3 #(2) strmux(2'b10,2'b01,2'b00,{funct3[1],funct3[0]},Mem_Data_length);

	lsu lsu(
		funct3, 
		LoadType, 
		StoreType);

	branch_unit branchunit(
		Branch, 
		Flags, 
		funct3, 
		branchtaken);

	assign PCWrite = branchtaken | PCUpdate;
endmodule
