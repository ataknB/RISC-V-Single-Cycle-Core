module Branch_Address_Cal(
	input logic [1:0]pc_control,
	/*
	01 normal
	10 jump branch
	11 branch
	00 NA
	
	
	*/
	input logic [31:0]imm_in,
	input logic [31:0]pc_value,
	
	
	output logic [31:0]branch_address_cal_out,
	output logic [31:0]branch_incremented_four
);
	logic [31:0]adder_result;
	
	Kogge_Stone Kogge_Stone_0(
		.in0(pc_value),
		.in1(32'd4),
		.sub_en(1'b0),
		.out(branch_incremented_four)	
	);
	
	Kogge_Stone Kogge_Stone_1(
		.in0(pc_value),
		.in1(imm_in),
		.sub_en(1'b0),
		.out(adder_result)	
	);
	
	assign branch_address_cal_out = (pc_control == 2'b01) ? pc_value : adder_result;
	
endmodule