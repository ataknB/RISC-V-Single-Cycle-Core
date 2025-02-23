module Control_Unit(

	input logic [4:0]op_code,
	input logic [3:0]sub_op_code,
	
	output logic imm_en, //aluda immediate value selector
	output logic rf_write_en, //register file write enable
	output logic mem_read_en, //memory read enable
	output logic mem_write_en, //memory write enable
	output logic [1:0]pc_control, //program counter control
	/*
	01 == normal
	10 == jump
	11 == branch
	00 == NA
	
	*/
	
	output logic sign_extender_en,
	output logic sign_extender_type,// 1 = unsigned , 0 = signed 

	output logic [3:0]alu_op //alu operation controller
	);
	
	always_comb
	begin
		
		casex(op_code)
			5'b0x101: //LUI and AUIPC
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					sign_extender_type	=	1'b0;
					pc_control			= 	2'b01;
			end

			5'b00100:// I Type
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					sign_extender_type	= 	(sub_op_code == 3'b011)	? 1'b1 : 1'b0;
					pc_control			= 	2'b01;
					
					casex(sub_op_code)
						4'bx000://addi
						begin	alu_op = 4'b0000; end
							
						4'bx01x://slti and sltiu
						begin	alu_op = 4'b1101; end
						
						4'bx100://xor
						begin	alu_op = 4'b0110; end

						4'bx01x://or
						begin	alu_op = 4'b0111; end
						
						4'bx01x://and
						begin	alu_op = 4'b1000; end

						4'b0001://sll
						begin	alu_op = 4'b0010; end

						4'b0101://srl
						begin	alu_op = 4'b0100; end	

						4'b1101://sra
						begin	alu_op = 4'b0101; end	

						default://default
						begin	alu_op = 4'd0; end							
						
					endcase
			end
			
			5'b01100:// R Type
			begin
					imm_en				= 	1'b0;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b0;
					sign_extender_type	=	1'b0;
					pc_control			= 	2'b01;
					
					casex(sub_op_code)
						4'b0000://add
						begin	alu_op = 4'b0000; end
							
						4'b1000://sub
						begin	alu_op = 4'b0001; end

						4'bx001://sll
						begin	alu_op = 4'b0010; end
						
						4'bx01x://slt-sltu
						begin	alu_op = 4'b1101; end

						4'bx100://xor
						begin	alu_op = 4'b0110; end

						4'b0101://srl
						begin	alu_op = 4'b0100; end						

						4'b1101://sra
						begin	alu_op = 4'b0101; end

						4'bx110://or
						begin	alu_op = 4'b0111; end

						4'bx111://and
						begin	alu_op = 4'b1000; end						
						
						default://default
						begin	alu_op = 4'd0; end							
						
					endcase					
			end
			
			5'b00000:// Load Type
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b1;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					alu_op 				= 	4'd0;
					pc_control			= 	2'b01;
				//	sign_extender_type	=	1'b0;
					
					casex(sub_op_code)
						4'bx0xx://lb
						begin	sign_extender_type	=	1'b0; end
						
						4'bx1xx://lbu
						begin	sign_extender_type	=	1'b1; end
						
						default://default
						begin	sign_extender_type	=	1'b0; end	
					endcase	
			end			
			
			5'b01000:// Store Type
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b0;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b1;
					sign_extender_en	=	1'b1;
					sign_extender_type	=	1'b0;
					alu_op 				= 	4'd0;
					pc_control			= 	2'b01;
	
			end
			
			5'b11011://JAL command
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					sign_extender_type	=	1'b0;
					pc_control			= 	2'b10;
					
			end
			
			5'b11001://JALR command
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					sign_extender_type	=	1'b0;
					pc_control			= 	2'b10;
					
			end
			
			5'b11000:// BRANCH Type
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					pc_control			= 	2'b11;
					
					casex(sub_op_code)
						4'bx000:// beq
						begin
							sign_extender_type	=	1'b0;
							alu_op				= 	4'b1001;
						end	
						
						4'bx001:// bne
						begin
							sign_extender_type	=	1'b0;
							alu_op				= 	4'b1010;
						end	
						
						4'bx100:// blt
						begin
							sign_extender_type	=	1'b0;
							alu_op				= 	4'b1011;
						end	
						
						4'bx101:// bge
						begin
							sign_extender_type	=	1'b1;
							alu_op				= 	4'b1100;
						end	
					
						4'bx110:// bltu
						begin
							sign_extender_type	=	1'b1;
							alu_op				= 	4'b1011;
						end	
						
						4'bx111:// bgeu
						begin
							sign_extender_type	=	1'b1;
							alu_op				= 	4'b1100;
						end	
						
						default:
						begin
							sign_extender_type	=	1'b0;
						end
					endcase
			end
			
			default:
			begin
					imm_en				= 	1'b0;
					rf_write_en 		= 	1'b0;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b0;
					sign_extender_type	=	1'b0;
					pc_control			= 	2'd0;
					alu_op				=	4'd0;
			end
		endcase
	end
	
	

endmodule