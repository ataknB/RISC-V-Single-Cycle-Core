module Single_Cycle_Core(
	input logic clk,
  	input logic rst
);

	logic [31:0]jump_address;
	logic [31:0]branch_address;
	logic [31:0]normal_address;

	logic [31:0]PC_out;

	logic [1:0]PC_controller;

	logic branch_en;
	logic normal_en;
	logic jump_en;

	assign branch_en = PC_controller[1] & PC_controller[0];
	assign jump_en = PC_controller[1] && ~PC_controller[0];

	Kogge_Stone PC_Increment(
		.in0(PC_out),
		.in1(32'd4),
		.sub_en(1'b0),
		.out(normal_address)
	);

	MUX_PC mux_pc(
		.jump_address(jump_address),
		.branch_address(branch_address),
		.normal_address(normal_address),

		.branch_en(branch_en),
		.normal_en(normal_en),
		.jump_en(jump_en),

		.PC_out(PC_in)
	);
	
	PC PC(
		.clk(clk),
		.rst(rst),

		.PC_in(PC_in),
		.PC_out(PC_out)
	);

	logic [31:0]Instruction_Memory_Out;

	Instruction_Memory Instruction_Memory(
		.Program_counter_IM(PC_out),
		.Instruction_IM(Instruction_Memory_Out)
	);	

	logic [4:0]op_code;
	logic [3:0]sub_op_code;

	logic [4:0]rs1;
	logic [4:0]rs2;
	logic [4:0]rd;

	logic [31:0]imm;
	logic [4:0]shift_size;

	Decoder Decoder(
		.inst(Instruction_Memory_Out),

		.op_code(op_code),
		.sub_op_code(sub_op_code),

		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),

		.imm(imm),
		.shift_size(shift_size)
	);

	logic [2:0]load_type;
	logic [1:0]store_type;

	logic Jal_en;
	logic JALR_en;

	logic imm_en;
	logic rf_write_en;
	logic mem_read_en;
	logic mem_write_en;
	logic [1:0]branch_mode;

	logic sign_extender_en;
	logic sign_extender_type;

	logic [3:0]alu_op;


	Control_Unit Control_Unit(
		.op_code(op_code),
		.sub_op_code(sub_op_code),

		.load_type(load_type),
		.store_type(store_type),

		.JAL_en(Jal_en),
		.JALR_en(JALR_en),

		.imm_en(imm_en),
		.rf_write_en(rf_write_en),
		.mem_read_en(mem_read_en),
		.mem_write_en(mem_write_en),
		.branch_mode(branch_mode),

		.sign_extender_en(sign_extender_en),
		.sign_extender_type(sign_extender_type),

		.alu_op(alu_op)
	);

	

	


	logic [31:0]wd;
	logic [31:0]rd1;
	logic [31:0]rd2;
	logic [31:0]rd2_RF_out;

	RF RF(
		.clk(clk),
		.rst(rst),

		.rs1(rs1),
		.rs2(rs2),	
		.rd(rd),
		.wd(wd),

		.write_en(rf_write_en),
		
		.rd1(rd1),
		.rd2(rd2_RF_out)	
	);

	logic [31:0]store_data;

	//RD2 
	always_comb
	begin
		case(store_type)
			2'b01: begin store_data = {24'd0 , rd2[7:0]}; end
			2'b10: begin store_data = {16'd0 , rd2[16:0]}; end
			2'b11: begin store_data = rd2; end
			default: begin store_data = 32'd0; end
		endcase
	end

	logic [31:0]imm_extended;

	Sign_Extender Sign_Extender(
		.in(imm),
		.op_code(op_code),

		.sign_extender_en(sign_extender_en),
		.sign_extender_type(sign_extender_type),

		.imm_out(imm_extended)
	);

	logic [31:0]alu_in1;
	logic [31:0]alu_in2;

	assign alu_in1 = (JAL_en) ? PC_out : rd1;
	
	//RD1
	always_comb
	begin
		case(store_type)
			2'b01: begin rd2 = {24'd0 , rd2[7:0]}; end
			2'b10: begin rd2 = {16'd0 , rd2[16:0]}; end
			2'b11: begin rd2 = rd2; end
			default: begin rd2 = 32'd0; end
		endcase

		if(sign_extender_en)
		begin
			alu_in2 = imm_extended;
		end

		else
		begin
			alu_in2 = rd2;
		end
	end
	
	logic [31:0]alu_out;
	logic branch_result_from_ALU;

	ALU ALU(
		.rs1(alu_in1),
		.rs2(alu_in2),
		.op(alu_op),

		.shifter_size(shift_size),
		
		.result(alu_out),
		.branch_control(branch_result_from_ALU)
	);

	assign jump_address = (JAL_en) ? (alu_out) : (JALR_en) ? {alu_out[31:1] , 1'b0} : {32'd0}; ;

	Kogge_Stone Branch_Calculator(
		.in0(PC_out),
		.in1(imm_extended),
		.sub_en(1'b0),
		.out(branch_address)
	);

	logic [31:0]memory_out;

	Memory Memory(
		.clk(clk),
		.rst(rst),

		.mem_read_en(mem_read_en),
		.mem_write_en(mem_write_en),

		.address(alu_out),
		.write_data(rd2),

		.read_data(memory_out)
	);

	logic [31:0]load_data;

	always_comb
	begin
		case(load_type)
			3'b001: begin load_data = {{24{memory_out[7]}}  , memory_out[7:0]}; end
			3'b010: begin load_data = {24'd0 , memory_out[7:0]}; end
			3'b011: begin load_data = {{16{memory_out[15]}} , memory_out[15:0]}; end
			3'b100: begin load_data = {16'd0              , memory_out[15:0]}; end
			3'b101: begin load_data = {memory_out[31:0]}; end
			default: begin load_data = 32'd0; end
		endcase

		if(mem_read_en)
		begin
			wd = load_data;
		end

		else if(jump_en)
		begin
			wd = normal_MEM;
		end

		else
		begin
			wd = alu_out;
		end	
	end



endmodule

module MUX_PC(
	input logic [31:0]jump_address,
	input logic [31:0]branch_address,
	input logic [31:0]normal_address,

	input logic branch_en,
	input logic normal_en,
	input logic jump_en,

	output logic [31:0]PC_out
);

	always_comb
	begin
		if(branch_en)
		begin
			PC_out = branch_address;
		end

		else if(jump_en)
		begin
			PC_out = jump_address;
		end

		else
		begin
			PC_out = normal_address;
		end
	end

endmodule