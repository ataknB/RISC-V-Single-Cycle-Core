module Control_Unit(

	input logic [4:0]op_code,
	input logic [3:0]sub_op_code,
	
	output logic imm_en, //aluda immediate value selector
	output logic rf_write_en, //register file write enable
	output logic mem_read_en, //memory read enable
	output logic mem_write_en, //memory write enable
	output logic [1:0]branch_mode, //program counter control
	/*
	01 == normal
	10 == jump
	11 == branch
	00 == NA
	
	*/
	output logic JALR_en,
	output logic JAL_en,
	output logic sign_extender_en,
	output logic sign_extender_type,// 1 = unsigned , 0 = signed 

	output logic [2:0]load_type,
	/*
		000 = NA
		001 = lb
		010 = lbu
		011 = lh
		100 = lhu
		101 = lw
	*/
	output logic [1:0]store_type,
	/*
		00 = NA
		01 = sb
		10 = sh
		11 = sw
	*/

	output logic [3:0]alu_op //alu operation controller
	);
	always_comb
	begin
		
		casex(op_code)
			5'b01101: //LUI
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					sign_extender_type	=	1'b0;
					branch_mode			= 	2'b01;
					JAL_en				=	1'b0;
					JALR_en				=	1'b0;
					load_type = 3'b000;
					store_type = 2'b00;
			end
			
			5'b00101: //LUI
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					sign_extender_type	=	1'b0;
					branch_mode			= 	2'b01;
					JAL_en				=	1'b0;
					JALR_en				=	1'b0;
					load_type = 3'b000;
					store_type = 2'b00;
			end

			5'b00100: // I Type
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					sign_extender_type	= 	(sub_op_code == 3'b011)	? 1'b1 : 1'b0;
					branch_mode			= 	2'b01;
					JAL_en				=	1'b0;
					JALR_en				=	1'b0;
					load_type = 3'b000;
					store_type = 2'b00;
					
					case(sub_op_code)
						4'b0000: //addi
						begin	alu_op = 4'b0000; end
						
						4'b1000: //addi
						begin	alu_op = 4'b0000; end
							
						4'b0010: //slti and sltiu
						begin	alu_op = 4'b1101; end
						
						4'b0011: //slti and sltiu
						begin	alu_op = 4'b1101; end
						
						4'b1010: //slti and sltiu
						begin	alu_op = 4'b1101; end
						
						4'b1011: //slti and sltiu
						begin	alu_op = 4'b1101; end
						
						4'b0100: //xor
						begin	alu_op = 4'b0110; end
						
						4'b1100: //xor
						begin	alu_op = 4'b0110; end

						4'b0110: //or
						begin	alu_op = 4'b0111; end
						
						4'b1110: //or
						begin	alu_op = 4'b0111; end
						
						4'b0011: //and
						begin	alu_op = 4'b1000; end
						
						4'b1011: //and
						begin	alu_op = 4'b1000; end

						4'b0001: //sll
						begin	alu_op = 4'b0010; end

						4'b0101: //srl
						begin	alu_op = 4'b0100; end	

						4'b1101: //sra
						begin	alu_op = 4'b0101; end	

						default: //default
						begin	alu_op = 4'd0; end							
						
					endcase
			end
			
			5'b01100: // R Type
			begin
					imm_en				= 	1'b0;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b0;
					sign_extender_type	=	1'b0;
					branch_mode			= 	2'b01;
					JAL_en				=	1'b0;
					JALR_en				=	1'b0;
					load_type = 3'b000;
					store_type = 2'b00;
					
					case(sub_op_code)
						4'b0000: //add
						begin	alu_op = 4'b0000; end
							
						4'b1000: //sub
						begin	alu_op = 4'b0001; end

						4'b0001: //sll
						begin	alu_op = 4'b0010; end
						
						4'b1001: //sll
						begin	alu_op = 4'b0010; end
						
						4'b0011: //sltu
						begin	alu_op = 4'b1101; end
						
						4'b1011: //sltu
						begin	alu_op = 4'b1101; end
						
						4'b0010: //slt
						begin	alu_op = 4'b1101; end
						
						4'b1010: //slt
						begin	alu_op = 4'b1101; end
						
						4'b1100: //xor
						begin	alu_op = 4'b0110; end
						
						4'b0100: //xor
						begin	alu_op = 4'b0110; end

						4'b0101: //srl
						begin	alu_op = 4'b0100; end						

						4'b1101: //sra
						begin	alu_op = 4'b0101; end

						4'b0110: //or
						begin	alu_op = 4'b0111; end
						
						4'b1110: //or
						begin	alu_op = 4'b0111; end

						4'b0111: //and
						begin	alu_op = 4'b1000; end	
						
						default: //default
						begin	alu_op = 4'd0; end							
						
					endcase					
			end
			
			5'b00000: // Load Type
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b1;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					alu_op 				= 	4'd0;
					branch_mode			= 	2'b01;
					sign_extender_type	=	1'b0;
					JAL_en				=	1'b0;
					JALR_en				=	1'b0;
					store_type = 2'b00;
					
					case(sub_op_code)
						4'b0000: //lb
						begin	load_type = 3'b001; end
						
						4'b0100: //lbu
						begin	load_type = 3'b010; end
						
						4'b0001: //lh
						begin	load_type = 3'b011; end
						
						4'b0101: //lhu
						begin	load_type = 3'b100; end
						
						4'b0010: //lw
						begin	load_type = 3'b101; end
						
						default://default
						begin	load_type = 3'b000; end	
					endcase	
			end			
			
			5'b01000: // Store Type
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b0;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b1;
					sign_extender_en	=	1'b1;
					sign_extender_type	=	1'b0;
					alu_op 				= 	4'd0;
					branch_mode			= 	2'b01;
					JAL_en				=	1'b0;
					JALR_en				=	1'b0;
					load_type = 3'b000;
					case(sub_op_code)
						4'b0_000:
						begin
							store_type = 2'b01;
						end
					
						4'b0_001:
						begin
							store_type = 2'b10;
						end
						
						4'b0_010:
						begin
							store_type = 2'b11;
						end
						default:
						begin
							store_type = 2'b00;
						end
					endcase
	
			end
			
			5'b11011: //JAL command
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					sign_extender_type	=	1'b0;
					branch_mode			= 	2'b10;
					JAL_en				=	1'b1;
					JALR_en				=	1'b0;
					load_type = 3'b000;
					store_type = 2'b00;
					
			end
			
			5'b11001: //JALR command
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					sign_extender_type	=	1'b0;
					branch_mode			= 	2'b10;
					JAL_en				=	1'b0;
					JALR_en				=	1'b1;
					load_type = 3'b000;
					store_type = 2'b00;
					
			end
			
			5'b11000: // BRANCH Type
			begin
					imm_en				= 	1'b1;
					rf_write_en 		= 	1'b1;
					mem_read_en			=	1'b0;
					mem_write_en		=	1'b0;
					sign_extender_en	=	1'b1;
					branch_mode			= 	2'b11;
					JAL_en				=	1'b0;
					JALR_en				=	1'b0;
					load_type 			= 	3'b000;
					store_type 			= 	2'b00;
					
					case(sub_op_code)
						4'b0000: // beq
						begin
							sign_extender_type	=	1'b0;
							alu_op				= 	4'b1001;
						end	
						
						4'b1000: // beq
						begin
							sign_extender_type	=	1'b0;
							alu_op				= 	4'b1001;
						end	
						
						4'b0001: // bne
						begin
							sign_extender_type	=	1'b0;
							alu_op				= 	4'b1010;
						end	
						
						4'b1001: // bne
						begin
							sign_extender_type	=	1'b0;
							alu_op				= 	4'b1010;
						end	
						
						4'b0100: // blt
						begin
							sign_extender_type	=	1'b0;
							alu_op				= 	4'b1011;
						end	
						
						4'b1100: // blt
						begin
							sign_extender_type	=	1'b0;
							alu_op				= 	4'b1011;
						end	
						
						4'b0101: // bge
						begin
							sign_extender_type	=	1'b1;
							alu_op				= 	4'b1100;
						end	
						
						4'b1101: // bge
						begin
							sign_extender_type	=	1'b1;
							alu_op				= 	4'b1100;
						end
					
						4'bx110: // bltu
						begin
							sign_extender_type	=	1'b1;
							alu_op				= 	4'b1011;
						end	
						
						4'bx111: // bgeu
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
					branch_mode			= 	2'd0;
					alu_op				=	4'd0;
					load_type = 3'b000;
					store_type = 2'b00;
			end
		endcase
	end
	
	

endmodule