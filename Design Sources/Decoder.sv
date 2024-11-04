module Decoder#(
	parameter FUNC = 3,
	parameter RS = 5,
	parameter RD = 5
	
	)(
	input logic  [31:0]inst,
	
	output logic [4:0]op_code,
	output logic [3:0]sub_op_code,
	
	output logic [RS-1:0]rs1, 
	output logic [RS-1:0]rs2,
	output logic [RD-1:0]rd,
	
	output logic [31:0]imm,
	output logic [4:0]shift_size
	);
	/*
		Şimdilik destekleyeceğim komutlar
		
		load write komutları
		imm kmmultarı 
		r komutları	
		branchler
		jumplar
	*/
	
	
	always_comb
	begin
		
		case(inst[6:2])
			5'b0x101: //lui and auipc
			begin
					op_code		    = 	inst[6:2];
					sub_op_code 	= 	{inst[30] , inst[14:12]};
					shift_size	    =	5'd0;					
					imm 			= 	{inst[31:12] , 12'd0};
					rs1				=	5'd0;
					rs2				=	5'd0;
					rd 				= 	{inst[11:7]};
			end
			
			5'b00100: // I Type
			begin
					op_code		    = 	inst[6:2];
					sub_op_code 	= 	{inst[30] , inst[14:12]};
					shift_size	    =	inst[24:20];
					imm				=	{20'd0 , inst[31:20]};
					rs1				=	inst[19:15];
					rs2				=	5'd0;
					rd				=	inst[11:7];	
					
			end
			
			5'b01100: //R Type
			begin
					op_code		    = 	inst[6:2];
					sub_op_code 	= 	{inst[30] , inst[14:12]};
					shift_size	    =	inst[24:20];
					imm				=	32'd0;
					rs1				=	inst[19:15]; 
					rs2				=	inst[24:20];
					rd				=	inst[11:7];
			end
			
			5'b00000:// Load Type
			begin
					op_code		    = 	inst[6:2];
					sub_op_code 	= 	{inst[30] , inst[14:12]};
					shift_size	    =	5'd0;
					imm				=	{20'd0 , inst[31:20]};
					rs1				=	inst[19:15]; 
					rs2				=	5'd0;
					rd				=	inst[11:7];
			end
			
			5'b01000:// Store Type
			begin
					op_code		    = 	inst[6:2];
					sub_op_code 	= 	{inst[30] , inst[14:12]};
					shift_size	    =	5'd0;
					imm				=	{{20{inst[31]}} , inst[31:25] , inst[11:7]};
					rs1				=	inst[19:15];
					rs2				=	inst[24:20];
					rd				=	5'd0;
			end			

			5'b11011:// Jump and Link
			begin
					op_code		    = 	inst[6:2];
					sub_op_code 	= 	{inst[30] , inst[14:12]};
					shift_size	    =	inst[24:20];
					imm				=	{{13{inst[31]}} , inst[19:12] , inst[20] , inst[30:21] , 1'b0};
					rs1				=	5'd0;
					rs2				=	5'd0;
					rd				=	inst[11:7];
			end			
	
			5'b11001:// Jump and Link Register
			begin
					op_code		    = 	inst[6:2];
					sub_op_code 	= 	{inst[30] , inst[14:12]};
					shift_size	    =	5'd0;
					imm				=	{{20{inst[31]}} , inst[31:20]};
					rs1				=	inst[19:15];
					rs2				=	5'd0;
					rd				=	inst[11:7];
			end	
			
			5'b11000:// Branch Type
			begin
					op_code		    = 	inst[6:2];
					sub_op_code 	= 	{inst[30] , inst[14:12]};
					shift_size	    =	5'd0;
					imm				=	{19'd0 , inst[31] , inst[7] , inst[30:25] , inst[11:8] , 1'b0};
					rs1				=	inst[19:15];
					rs2				=	inst[24:20];
					rd				=	5'd0;
			end
			
			default:
			begin
					op_code		    = 	5'd0;
					sub_op_code 	= 	4'd0;
					shift_size	    =	5'd0;
					imm				=	32'd0;
					rs1				=	5'd0;
					rs2				=	5'd0;
					rd				=	5'd0;			
			end
	
		endcase
	end
		
endmodule	