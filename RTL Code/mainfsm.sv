module mainfsm(
	input  clk,
	input  rst_n,
	input   [6:0] op,
	input is_posedge, 
	output   [1:0] ALUSrcA, ALUSrcB,
	output   [1:0] ResultSrc,
	output   AdrSrc,
	output   IRWrite, PCUpdate,
	output   RegWrite, MemWrite,
	output   [1:0] ALUOp,
	output   Branch,
	output   Mem_Read_En,Mem_En);

	//parameter FETCH          = 4'b0000; 
    //parameter FETCHBUFF      = 4'b0001; 
   // parameter DECODE         = 4'b0010;
   // parameter MEMADR         = 4'b0011;
   // parameter MEMREAD        = 4'B0100; 
   // parameter MEMREADBUFF    = 4'b0101; 
   // parameter MEMWB          = 4'b0110;
   // parameter MEMWRITE       = 4'b0111;
	///
	///parameter EXECUTER       = 4'b1000;
   // parameter EXECUTEI       = 4'B1001; 
   // parameter  ALUWB         = 4'b1010; 
   // parameter  BEQ           = 4'b1011;
   // parameter JAL            = 4'b1100;
	//parameter AUIPC          = 4'b1101;
	//parameter UNKNOWN        =4'b1110;
	

	typedef enum logic [3:0] {
	FETCH,FETCHBUFF, DECODE, MEMADR, MEMREAD,MEMREADBUFF,
	MEMWB, MEMWRITE,
	EXECUTER, EXECUTEI, ALUWB,
	BEQ, JAL,AUIPC, UNKNOWN
	} statetype;

	statetype state, nextstate;
	logic [14:0] controls;
	
	//reg [3:0] state, nextstate;
	//reg [15:0] controls;

	// state register
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			state <= FETCH;
		else 	
			state <= nextstate;
	end 

	// next state logic
	always @(*)  begin
		case(state)
			FETCH: nextstate = is_posedge? FETCH: FETCHBUFF;
			FETCHBUFF: nextstate = DECODE;
			DECODE: casez(op)
				7'b0?00011: nextstate = MEMADR; // lw or sw
				7'b0110011: nextstate = EXECUTER; // R-type
				7'b0010011: nextstate = EXECUTEI; // addi
				7'b1100011: nextstate = BEQ; // beq
				7'b1100111: nextstate = MEMADR; //JALR addition
				7'b1101111: nextstate = JAL; // jal
				7'b0010111: nextstate = AUIPC; // AUIPC addition
				7'b0110111: nextstate = MEMADR;// LUI addition
				default: nextstate = UNKNOWN;
			endcase
			MEMADR: begin
				if (op==7'b1100111)
				   nextstate = JAL;
				else if (op==7'b0110111)   // LUI addition
				   nextstate = ALUWB;	   // LUI addition
				else
					if (op[5]) 
						nextstate = MEMWRITE; // sw
					else 
						nextstate = MEMREAD; // lw
			end 
			//MEMREAD: nextstate = MEMWB;
			MEMREAD: nextstate = MEMREADBUFF;
			MEMREADBUFF: nextstate = MEMWB;
			AUIPC :  nextstate = ALUWB; // addition
			EXECUTER: nextstate = ALUWB;
			EXECUTEI: nextstate = ALUWB;
			JAL: nextstate = ALUWB;
			default: nextstate = FETCH;
		endcase
	end

	// state-dependent output logic
	always @(*)  begin
		case(state)
			FETCH: 		controls = 16'b00_10_10_0_1000_00_0_0;
			FETCHBUFF:      controls = 16'b00_10_10_0_1100_00_0_1;
			DECODE: 	controls = 16'b01_01_00_0_0000_00_0_0;
			MEMADR: 	controls = 16'b10_01_00_0_0000_00_0_0;
			AUIPC:		controls = 16'b01_01_00_0_0000_00_0_0; // addition
			MEMREAD: 	controls = 16'b00_00_00_1_0000_00_0_1;
			MEMREADBUFF: 	controls = 16'b00_00_00_1_0000_00_0_1;
			MEMWRITE: 	controls = 16'b00_00_00_1_0001_00_0_0;
			MEMWB: 		controls = 16'b00_00_01_0_0010_00_0_0;
			EXECUTER:	controls = 16'b10_00_00_0_0000_10_0_0;
			EXECUTEI: 	controls = 16'b10_01_00_0_0000_10_0_0;
			ALUWB: 		controls = 16'b00_00_00_0_0010_00_0_0;
			BEQ: 		controls = 16'b10_00_00_0_0000_01_1_0;
			JAL: 		controls = 16'b01_10_00_0_0100_00_0_0;
			default: 	controls = 16'bxx_xx_xx_x_xxxx_xx_x_x;
		endcase
	end 

	assign {ALUSrcA, ALUSrcB, ResultSrc, AdrSrc, IRWrite, PCUpdate,	RegWrite,MemWrite, ALUOp, Branch, Mem_Read_En} = controls;
endmodule 

