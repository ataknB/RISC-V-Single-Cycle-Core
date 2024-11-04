module ALU #(
		parameter WIDTH = 32,
		parameter OP = 4
	)
	(
		input logic [WIDTH-1:0]rs1, 
		input logic [WIDTH-1:0]rs2, 
		input logic [OP-1:0]op, 
		input logic [4:0]shifter_size,
	/*
		0 add = 4'b0000
		1 sub = 4'b0001
		
		2 sll = 4'b0010
		3 sla = 4'b0011
		4 srl = 4'b0100
		5 sra = 4'b0101
		
		6 xor = 4'b0110
		7 or = 4'b0111
		8 and = 4'b1000
		
		9 beq = 4'b1001
		10 bne = 4'b1010
		11 blt = 4'b1011
		12 bge = 4'b1100
		
		13 slt = 4'b1101
		
	*/	
		
		output logic [WIDTH-1:0]result,
		output logic branch_control //1 jump branch 0 - dont jump
	);
	
	logic sub_en;
	logic [WIDTH-1:0]out_kogge_stone;
	logic overflow;	
	
	logic sra_en,sll_en;
	logic xor_en,and_en,or_en;
	logic [WIDTH-1:0]out_shifter;
	

	
	always_comb
		begin
		
			case(op)
				4'b0000: begin sub_en = 1'b0; 	sra_en = 1'b0; 		sll_en = 1'b0; 	 		xor_en = 1'b0; 	or_en = 1'b0;	 and_en = 1'b0;	 end //add
				4'b0001: begin sub_en = 1'b1; 	sra_en = 1'b0; 		sll_en = 1'b0; 	 		xor_en = 1'b0; 	or_en = 1'b0;	 and_en = 1'b0;	 end //sub
				
				4'b0010: begin sub_en = 1'b0; 	sra_en = 1'b0; 		sll_en = 1'b1; 	 	xor_en = 1'b0; 	or_en = 1'b0;	 and_en = 1'b0;	 end //sll
				4'b0011: begin sub_en = 1'b0; 	sra_en = 1'b0; 		sll_en = 1'b1; 	 	xor_en = 1'b0; 	or_en = 1'b0;	 and_en = 1'b0;	 end //sla
				4'b0100: begin sub_en = 1'b0; 	sra_en = 1'b0; 		sll_en = 1'b0; 	 	xor_en = 1'b0; 	or_en = 1'b0;	 and_en = 1'b0;	 end //srl
				4'b0101: begin sub_en = 1'b0; 	sra_en = 1'b1; 		sll_en = 1'b0; 	 	xor_en = 1'b0; 	or_en = 1'b0;	 and_en = 1'b0;	 end //sra
				
				4'b0110: begin sub_en = 1'b0; 	sra_en = 1'b0; 		sll_en = 1'b0; 			xor_en = 1'b1; 	or_en = 1'b0;	 and_en = 1'b0;	 end //xor
				4'b0111: begin sub_en = 1'b0; 	sra_en = 1'b0; 		sll_en = 1'b0; 	 		xor_en = 1'b0; 	or_en = 1'b1;	 and_en = 1'b0;	 end //or
				4'b1000: begin sub_en = 1'b0; 	sra_en = 1'b0; 		sll_en = 1'b0; 	 		xor_en = 1'b0; 	or_en = 1'b0;	 and_en = 1'b1;	 end //and
				
				4'b1001 , 4'b1010 , 4'b1011 , 4'b1100 , 4'b1101: begin sub_en = 1'b1; 	sra_en = 1'b0; 		sll_en = 1'b0;  		xor_en = 1'b0; 	or_en = 1'b0;	 and_en = 1'b0;	 end //beq
				
			endcase				
		end
	
	Kogge_Stone Kogge_Stone_(
		.in0(rs1),
		.in1(rs2),
		.sub_en(sub_en),
		.out(out_kogge_stone),
		.overflow(overflow)
	);

	Shifter Shifter_(
		.in(rs1),
		.sra(sra_en),
		.sll(sll_en),
		.size(shifter_size),
		.out(out_shifter)
	);
	
	assign branch_control 	= 	(op == 4'b0110) ?  	!(&out_kogge_stone[31:0]) 			? 1'b1 : 1'b0	:  
								(op	== 4'b1010)	?  	(|out_kogge_stone[31:0])   			? 1'b1 : 1'b0 :
								(op == 4'b1011) ?  	(!overflow && out_kogge_stone[31]) 	? 1'b1 : 1'b0:
								(op == 4'b1100) ?	(!(&out_kogge_stone[31:0]) || (!(overflow || out_kogge_stone[31]))) ? 1'b1 : 1'b0: 1'b0;
	
	logic out_logic 		= 	(op == 4'd6) ? rs1 ^ rs2	:
								(op == 4'd7) ? rs1 | rs2	:
								(op == 4'd8) ? rs1 & rs2	: 32'd0;
	
	logic out_compare		=	(compare_op && out_kogge_stone[31] && !overflow) ? 32'd1 : 32'd0;
	/*
	assign result 			=	(arithmetic_op) ? 	out_kogge_stone : 
								(logic_op)		? 	out_logic		: 
								(shifting_op)	?	out_shifter		:
								(compare_op)	?	out_compare     :
								32'd0;
	*/		

	logic arithmetic_op 	= 	( (op == 4'b0000) || (op == 4'b0001) ) ? 1'b1: 1'b0;
	
	logic logic_op			=	(op == 4'b0110) || (op == 4'b0111) ||(op == 4'b1000) ? 1'b1: 1'b0;
								
	
	logic branch_op			=	(op == 4'b1001) || (op == 4'b1010) ||  
								(op == 4'b1011) || (op == 4'b1100) ? 1'b1: 1'b0; 
								
	logic compare_op		=	(op == 4'b1101) ? 1'b1: 1'b0;
	
	logic shifting_op		=	(op == 4'b0010) || (op == 4'b0011) || 
								(op == 4'b0100) || (op == 4'b0101) ? 1'b1: 1'b0;
	
	always_comb
	begin
		
		case(op)
			4'b0000 , 4'b0001: //arithmetic_op
			begin
				arithmetic_op 	=	1'b1;
				logic_op		=	1'b0;
				branch_op		=	1'b0;
				compare_op		=	1'b0;
				shifting_op		=	1'b0;
			end
			
			4'b0110 , 4'b0111 , 4'b1000: // logic_op
			begin
				arithmetic_op 	=	1'b0;
				logic_op		=	1'b1;
				branch_op		=	1'b0;
				compare_op		=	1'b0;
				shifting_op		=	1'b0;
			end
			
			4'b0110 , 4'b0111 , 4'b1000: // branch
			begin
				arithmetic_op 	=	1'b0;
				logic_op		=	1'b0;
				branch_op		=	1'b1;
				compare_op		=	1'b0;
				shifting_op		=	1'b0;
			end
			
			4'b0110 , 4'b0111 , 4'b1000: // compare
			begin
				arithmetic_op 	=	1'b0;
				logic_op		=	1'b0;
				branch_op		=	1'b0;
				compare_op		=	1'b1;
				shifting_op		=	1'b0;
			end
			
			4'b0110 , 4'b0111 , 4'b1000: // shifting
			begin
				arithmetic_op 	=	1'b0;
				logic_op		=	1'b0;
				branch_op		=	1'b0;
				compare_op		=	1'b0;
				shifting_op		=	1'b1;
			end
			
			default:
			begin
				begin
				arithmetic_op 	=	1'b0;
				logic_op		=	1'b0;
				branch_op		=	1'b0;
				compare_op		=	1'b0;
				shifting_op		=	1'b0;
			end
			end
			
			
		endcase
		
	
		if(arithmetic_op)
		begin
			result = out_kogge_stone;
		end
		
		else if(logic_op)
		begin
			result = out_logic;
		end
		
		else if(shifting_op)
		begin
			result = out_shifter;
		end
		
		else if(compare_op)
		begin
			result = out_compare;
		end
		
		else 
		begin
			result = 32'd0;
		end
	end
	
endmodule