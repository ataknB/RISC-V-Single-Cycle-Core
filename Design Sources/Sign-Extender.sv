module Sign_Extender(
	input logic [31:0]in,
	input logic [4:0]op_code,
	input logic sign_extender_en,
	input logic sign_extender_type, // 0 = signed 1 = unsigned 
	
	output logic [31:0]imm_out
);

	always_comb
	begin
		if(sign_extender_en)
		begin
			case(op_code)
				5'b0x101: // LUI and AUIPC
				begin
					imm_out		= 	in;
				end
				
				5'b00100: // I Type
				begin
					imm_out 	=	(sign_extender_type)	? {20'd0 , in[11:0]} : {{20{in[11]}} , in[11:0]};
				end
				
				5'b00000: // LOAD Type
				begin
					imm_out		=	(sign_extender_type)	? {20'd0 , in[11:0]} : {{20{in[11]}} , in[11:0]};
				end
				
				5'b01000: // STORE Type
				begin
					imm_out		=	in;
				end
				
				5'b110x1: // JAL-JALR Type
				begin
					imm_out		=	in;
				end
				
				5'b11000: // BRANCH Type
				begin
					imm_out		=	(sign_extender_type)	? {19'd0 , in[12:0]} : {{19{in[11]}} , in[12:0]};
				end
				
				default:
				begin
					imm_out		=	32'd0;
				end
			endcase	
		end
		
		else
		begin
			imm_out		=	32'd0;
		end
	end

	
endmodule