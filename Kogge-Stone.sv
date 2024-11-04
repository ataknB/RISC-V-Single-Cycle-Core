module Kogge_Stone#(
	parameter WIDTH = 32,
	parameter X = 161
	)(
	input logic [WIDTH-1 : 0]in0,
	input logic [WIDTH-1 : 0]in1,
	input logic sub_en,// 1 = en
	
	output logic overflow,
	output logic [WIDTH-1 : 0]out
	
	);

	wire [WIDTH-1 : 0]wire_in0;
	wire [WIDTH-1 : 0]wire_in1;
	
	wire [X-1:0]wire_prop;
	wire [X-1:0]wire_gen;
	
	wire [32 : 0]wire_carry;	
	assign wire_carry[0] = sub_en;
	
	genvar i;
	generate 
		for(i=0 ; i<32 ; i=i+1)begin
			assign wire_in1[i] = in1[i] ^ wire_carry[0];
			assign wire_in0[i] = in0[i];
		end
	endgenerate
	
	generate 
	//stage 0
	for(i=0 ; i<32 ; i=i+1)begin 
		assign wire_prop[i] = wire_in0[i] ^ wire_in1[i];
		assign wire_gen[i] = wire_in1[i] & wire_in0[i];
	end 
	//stage 1
	for(i=32 ; i<63 ; i=i+1)begin 
		assign wire_prop[i] = wire_prop[i-31] & wire_prop[i-32];
		assign wire_gen[i] = wire_gen[i-31] | (wire_prop[i-31] & wire_gen[i-32]); 
	end 
endgenerate


    //stage 2
    assign wire_prop[63] = wire_prop[33] & wire_prop[0];
    assign wire_gen[63] = wire_gen[33] | (wire_prop[33] & wire_gen[0]);
    
    generate 
    for(i=64 ; i<93 ; i=i+1)begin 
        assign wire_prop[i] = wire_prop[i-30] & wire_prop[i-32];
        assign wire_gen[i] = wire_gen[i-30] | (wire_prop[i-30] & wire_gen[i-32]);
    end
    endgenerate
    
    //stage 3
    
    assign wire_prop[93] = wire_prop[65] & wire_prop[0];
    assign wire_gen[93] = wire_gen[65] | (wire_prop[65] & wire_gen[0]);
    
    assign wire_prop[94] = wire_prop[66] & wire_prop[32];
    assign wire_gen[94] = wire_gen[66] | (wire_prop[66] & wire_gen[32]);
    
    generate 
        for(i=95 ; i<121 ;i=i+1)begin 
            assign wire_prop[i] = wire_prop[i-28] & wire_prop[i-32];
            assign wire_gen[i] = wire_gen[i-28] | (wire_prop[i-28] & wire_gen[i-32]);
        end
    endgenerate
    
    //stage 4
    
    assign wire_prop[121] = wire_prop[97] & wire_prop[0];
    assign wire_gen[121] = wire_gen[97] | (wire_prop[97] & wire_gen[0]);
    
    assign wire_prop[122] = wire_prop[98] & wire_prop[32];
    assign wire_gen[122] = wire_gen[98] | (wire_prop[98] & wire_gen[32]);
    
    assign wire_prop[123] = wire_prop[99] & wire_prop[63];
    assign wire_gen[123] = wire_gen[99] | (wire_prop[99] & wire_gen[63]);
    
    assign wire_prop[124] = wire_prop[100] & wire_prop[64];
    assign wire_gen[124] = wire_gen[100] | (wire_prop[100] & wire_gen[64]);
    
    generate 
    for(i=125 ; i<145 ; i=i+1)begin 
        assign wire_prop[i] = wire_prop[i-24] & wire_prop[i-32];
        assign wire_gen[i] = wire_gen[i-24] | (wire_prop[i-24] & wire_gen[i-32]);
    end 
    endgenerate
    //stage 5
    assign wire_prop[145] = wire_prop[129] & wire_prop[0];
    assign wire_gen[145] = wire_gen[129] | (wire_prop[129] & wire_gen[0]);
    
    assign wire_prop[146] = wire_prop[130] & wire_prop[32];
    assign wire_gen[146] = wire_gen[130] | (wire_prop[130] & wire_gen[32]);
    
    assign wire_prop[147] = wire_prop[131] & wire_prop[63];
    assign wire_gen[147] = wire_gen[131] | (wire_prop[131] & wire_gen[63]);
    
    assign wire_prop[148] = wire_prop[132] & wire_prop[64];
    assign wire_gen[148] = wire_gen[132] | (wire_prop[132] & wire_gen[64]);
    
    assign wire_prop[149] = wire_prop[133] & wire_prop[93];
    assign wire_gen[149] = wire_gen[133] | (wire_prop[133] & wire_gen[93]);
    
    assign wire_prop[150] = wire_prop[134] & wire_prop[94];
    assign wire_gen[150] = wire_gen[134] | (wire_prop[134] & wire_gen[94]);
    
    assign wire_prop[151] = wire_prop[135] & wire_prop[95];
    assign wire_gen[151] = wire_gen[135] | (wire_prop[135] & wire_gen[95]);
    
    assign wire_prop[152] = wire_prop[136] & wire_prop[96];
    assign wire_gen[152] = wire_gen[136] | (wire_prop[136] & wire_gen[96]);
    
    generate 
    for(i=153 ; i<161 ; i=i+1)begin
        assign wire_prop[i] = wire_prop[i-16] & wire_prop[i-32] ;
        assign wire_gen[i] = wire_gen[i-16] | (wire_prop[i-16] & wire_gen[i-32]);
    end
    endgenerate
    //stage 0
	assign wire_carry[1] = wire_gen[0] | (wire_prop[0] & wire_carry[0]);
	//stage 1
	assign wire_carry[2] = wire_gen[32] | (wire_prop[32] & wire_carry[0]);
	//stage 2
	assign wire_carry[3] = wire_gen[63] | (wire_prop[63] & wire_carry[0]);
	assign wire_carry[4] = wire_gen[64] | (wire_prop[64] & wire_carry[0]);
	//stage 3
	assign wire_carry[5] = wire_gen[93] | (wire_prop[93] & wire_carry[0]);
	assign wire_carry[6] = wire_gen[94] | (wire_prop[94] & wire_carry[0]);
	assign wire_carry[7] = wire_gen[95] | (wire_prop[95] & wire_carry[0]);
	assign wire_carry[8] = wire_gen[96] | (wire_prop[96] & wire_carry[0]);
	//stage 4
	assign wire_carry[9] = wire_gen[121] | (wire_prop[121] & wire_carry[0]);
	assign wire_carry[10] = wire_gen[122] | (wire_prop[122] & wire_carry[0]);
	assign wire_carry[11] = wire_gen[123] | (wire_prop[123] & wire_carry[0]);
	assign wire_carry[12] = wire_gen[124] | (wire_prop[124] & wire_carry[0]);
	assign wire_carry[13] = wire_gen[125] | (wire_prop[125] & wire_carry[0]);
	assign wire_carry[14] = wire_gen[126] | (wire_prop[126] & wire_carry[0]);
	assign wire_carry[15] = wire_gen[127] | (wire_prop[127] & wire_carry[0]);
	assign wire_carry[16] = wire_gen[128] | (wire_prop[128] & wire_carry[0]);
	
	generate 
		for(i=145 ; i<161 ; i= i+1)begin 
			assign wire_carry[i-128] = wire_gen[i] | (wire_prop[i] & wire_carry[0]);
		end 
	endgenerate
	
	wire [31:0]wire_out;
	
    //Sum
	generate 
		for(i=0 ; i<32 ; i=i+1)begin 
			assign wire_out[i] = wire_carry[i] ^ wire_prop[i];
		end
	endgenerate
	
	assign out = wire_out;
	
	wire sign0 = in0[31];
	wire sign1 = in1[31];
	wire sign_out = out[31];
	
	assign overflow = sub_en ? (!sign0 && sign1) || (sign0 && !sign1) :	(sign0 && sign1) || !(sign0 && sign1);
	
endmodule






