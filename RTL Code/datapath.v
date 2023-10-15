module datapath(
	input   clk, rst_n,
	input   [2:0] ImmSrc,
	input   [1:0] ALUSrcA, ALUSrcB,
	input   [1:0] ResultSrc,
	input   AdrSrc,
	input   IRWrite, PCWrite,

	input   RegWrite, MemWrite,
	input   [3:0] alucontrol,
	input   LoadType, StoreType, // lbu, sb
	input   PCTargetSrc,
	output   [6:0] op,
	output   [2:0] funct3,
	output   funct7b5,
	output   [3:0] Flags,
	output   [31:0] Adr,
	input   [31:0] ReadData,
	output   [31:0] WriteData);

	wire [31:0] PC, OldPC, Instr, immext, ALUResult;
	wire [31:0] SrcA, SrcB, RD1, RD2, A;
	wire [31:0] Result, Data, ALUOut;
	wire [4:0] RS1;
	wire lui_cs;  // for lui
	
	// for addition for lb,lh,lbu,lhu
	wire [31:0] lb,lbu,lb_final;
	wire [31:0] lh,lhu,lh_final;
	wire [31:0] lb_OR_lh,loadData;
	
	
	// next PC logic
	flop #(32) pcreg(clk, rst_n, PCWrite, Result, PC);
	flop #(32) oldpcreg(clk, rst_n, IRWrite, PC, OldPC);
	
	// memory logic
	mux2 #(32) adrmux(PC, Result, AdrSrc, Adr);
	flop #(32) ir(clk, rst_n, IRWrite, ReadData, Instr);
	flipr #(32) datareg(clk, rst_n, loadData, Data);
	
	// addition for lb,lh,lbu,lhu
	// sign extension
	assign lb = {{20{ReadData[7]}},ReadData[7:0]};
	assign lbu = {{20{1'b0}},ReadData[7:0]};
	assign lh = {{16{ReadData[15]}},ReadData[15:0]};
	assign lhu = {{16{1'b0}},ReadData[15:0]};
	// muxing  for lb,lh,lbu,lhu
	mux2 #(32) lbmux(lb,lbu,funct3[2],lb_final);
	mux2 #(32) lhmux(lh,lhu,funct3[2],lh_final);
	mux2 #(32) lblhmux(lb_final,lh_final,funct3[0],lb_OR_lh);
	mux2 #(32) loadmux(lb_OR_lh,ReadData,funct3[1],loadData);
	
	assign lui_cs=~op[6]&op[5]&op[4]&~op[3]&op[2]&op[1]&op[0]; // cs for control signal
	mux2 #(5) lui_mux(Instr[19:15],4'd0,lui_cs,RS1);
	// register file logic
	registerfile rf(
		clk, 
		rst_n,
		RegWrite, 
		RS1, 
		Instr[24:20],
	
		Instr[11:7], 
		Result, 
		RD1, 
		RD2);

	extend ext(
		Instr[31:7], 
		ImmSrc, 
		immext);

	flipr #(32) srcareg(clk, rst_n, RD1, A);
	flipr #(32) wdreg(clk, rst_n, RD2, WriteData);

	// ALU logic
	mux3 #(32) srcamux(PC, OldPC, A, ALUSrcA, SrcA);
	mux3 #(32) srcbmux(WriteData, immext, 32'd4, ALUSrcB, SrcB);
	alu alu(SrcA, SrcB, alucontrol, ALUResult, Flags);
	flipr #(32) aluoutreg(clk, rst_n, ALUResult, ALUOut);
	mux3 #(32) resmux(ALUOut, Data, ALUResult, ResultSrc, Result);

	// outputs to control unit
	assign op = Instr[6:0];
	assign funct3 = Instr[14:12];
	assign funct7b5 = Instr[30];
endmodule
