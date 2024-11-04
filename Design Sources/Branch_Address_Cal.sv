module Branch_Address_Cal(
	input logic [1:0]pc_control,
	input logic [31:0]imm_in,
	input logic [31:0]pc_incremented_four,
	
	output logic [31:0]branch_address_cal_out
);
	logic [31:0]adder_result;
	logic [31:0]shifted_value = {imm_in[31:2] , 2'd0};
	
	Kogge_Stone Kogge_Stone_(
		.in0(shifted_value),
		.in1(pc_incremented_four),
		.sub_en(1'b0),
		.out(adder_result)	
	);
	
	assign branch_address_cal_out = (&(pc_control[1:0])) ? adder_result : shifted_value;
	
endmodule