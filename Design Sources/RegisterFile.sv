module RF#(
	parameter RS = 5,
	parameter RD = 32
	
	)(
	input logic [RS-1:0]rs1,
	input logic [RS-1:0]rs2,
	input logic [RS-1:0]rd,
	input logic [RD-1:0]wd,
	
	input logic clk,
	input logic rst,
	input logic write_en,
	
	output logic [RD-1:0]rd1,
	output logic [RD-1:0]rd2
	
);	
	reg [31:0]reg_data[31:0];// first[31:0] refeer to  register
	
	assign rd1 = reg_data[rs1];
	assign rd2 = reg_data[rs2];
	
	
	always_ff @(posedge clk or negedge rst) 
	begin
		
		reg_data[0] <= 1'b0;
		
		if(!rst)
		begin
		    integer i;
			for(i=0 ; i<32 ; i=i+1)
			   begin
				   reg_data[i] <= 32'd0;
			   end
		end	
		
		else
		begin
			if(write_en)
			begin
				reg_data[rd] <= wd;
			end    
			
			else  
			begin 
				reg_data <= reg_data;
			end
		end
	end
    
    assign rd1 = reg_data[rs1];  
    assign rd2 = reg_data[rs2];  

endmodule