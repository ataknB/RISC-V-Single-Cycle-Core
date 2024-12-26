module processor_top(
	input logic clk,
	input logic rst
);
    logic [31:0]instructionMemory_out;
	
	//alu signals
		
	
	//program counter signals
	
	logic 	[31:0]PC_in;
	logic 	[31:0]PC_out;	
	logic   [31:0]branch_address_cal_out;
	logic   [1:0]pc_control;
	logic	[31:0]PC_Next;
	
	
	PC_MUX PC_MUX_(
		.pc_control(pc_control),
		.branch_address_cal_out(branch_address_cal_out),
		.pc_incremented_four(PC_Next),
		.PC_in(PC_in)
	);
	
	PC PC_(
		.clk(clk),
		.rst(rst),
		
		.PC_in(PC_in),
		.PC_out(PC_out)
	);
	
	assign PC_Next = PC_out + 32'd4;

	
	Instruction_Memory Instruction_Memory_(
        .Program_counter_IM(PC_out),          
        .Instruction_IM(instructionMemory_out)     
    );
	
	logic [4:0]op_code;
	logic [3:0]sub_op_code;
	
	logic [4:0]rs1;
	logic [4:0]rs2;
	logic [4:0]rd;
	
	logic [31:0]imm;
	logic [4:0]shifter_size;
	logic [3:0]alu_op;
	
	Decoder Decoder_(
        .inst(instructionMemory_out),
        
        .op_code(op_code),
        .sub_op_code(sub_op_code),
        
        .rs1(rs1), 
        .rs2(rs2),
        .rd(rd),
        
        .imm(imm),
        .shift_size(shifter_size)
    );
	
	logic imm_en, rf_write_en, mem_read_en, mem_write_en, sign_extender_en, sign_extender_type;
	
	Control_Unit control_unit_(
        .op_code(op_code),
        .sub_op_code(sub_op_code),
        .imm_en(imm_en),
        .rf_write_en(rf_write_en),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .pc_control(pc_control),
        .sign_extender_en(sign_extender_en),
        .sign_extender_type(sign_extender_type),
        .alu_op(alu_op)
    );
	
	logic [31:0]wd_in;
	logic [31:0]alu_in1;
		 
	
	logic [31:0]alu_out;
	logic alu_branch_control;
	logic [31:0]rd2;
	logic [31:0]sign_extender_out;	
	logic branch_control;
	
	
	RF RF_(
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd_in),
		
        .clk(clk),
        .rst(rst),
		
        .write_en(rf_write_en),
        .rd1(alu_in1),
        .rd2(rd2)
    );
	

	
	Sign_Extender sign_extender_(
        .in(imm),
        .op_code(op_code),
        .sign_extender_en(sign_extender_en),
        .sign_extender_type(sign_extender_type),
        .imm_out(sign_extender_out)
    );
	
	logic [31:0]alu_in2;
	assign alu_in2		= 	 (sign_extender_en) ? (sign_extender_out) : (rd2);
	
	ALU ALU_(
        .rs1(alu_in1),
        .rs2(alu_in2),
		.shifter_size(shifter_size),
        .op(alu_op),
        .result(alu_out),
        .branch_control(alu_branch_control)
    );
	
	assign branch_control = alu_branch_control && pc_control[1] && pc_control[0];
	
	Branch_Address_Cal Branch_Address_Cal_(
		.pc_control(pc_control),
		.pc_value(PC_out),
		.imm_in(sign_extender_out),
		.branch_incremented_four(PC_Next),
		.branch_address_cal_out(branch_address_cal_out)
);
	
	logic [31:0]memory_out;
	
	Memory Memory_(
    .mem_read_en(mem_read_en),
    .mem_write_en(mem_write_en),
    .clk(clk),
    .rst(rst),
    .address(alu_out),
    .write_data(rd2),
    .read_data(memory_out)
);
	
	RF_Write_MUX RF_Write_MUX_(
		.alu_out(alu_out),
		.memory_out(memory_out),
		.pc_value(PC_Next),
		.op_code(op_code),
		.wd_in(wd_in)
		
	);
	
endmodule
/*

module PC(
	input logic	clk, 
	input logic rst,
	
	input logic [31:0]PC_in,
	output logic [31:0]PC_out
);

	always_ff @(posedge clk or negedge rst)
	begin
		
		if(!rst)
		begin
			PC_out <= 32'd0;
		end
		
		else
		begin
			PC_out <= PC_in;
 		end
		
	end
endmodule
*/
module PC_MUX #(
	parameter SIZE = 32
	)(
	input logic	[SIZE-1:0]pc_incremented_four,
	input logic	[SIZE-1:0]branch_address_cal_out,
	input logic [1:0]pc_control,
	
	output logic [SIZE-1:0]PC_in
);
	always_comb
	begin
		case(pc_control)
			2'b01:
			begin
				PC_in = pc_incremented_four;
			end
			
			2'b10:
			begin
				PC_in = branch_address_cal_out;
			end
			
			2'b11:
			begin
				PC_in = branch_address_cal_out;
			end
			
			default:
			begin
				PC_in = 32'd0;
			end
		endcase
	end

endmodule

module RF_Write_MUX(
	input logic [31:0]alu_out,
	input logic [31:0]memory_out,
	input logic [31:0]pc_value,
	
	input logic [4:0]op_code,
	
	output logic [31:0]wd_in
	);
	
	always_comb
	begin
		case(op_code)
			5'b00000: //LOAD
			begin
				wd_in = memory_out;
			end
			
			5'b11011: //JAL
			begin
				wd_in = pc_value;
			end
			
			5'b11001: //JALR
			begin
				wd_in = alu_out;
			end
			
			default:
			begin
				wd_in = alu_out;
			end
			
		endcase
	end
	
endmodule