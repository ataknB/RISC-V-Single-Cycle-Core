module Memory #(
	)(
		input logic mem_read_en,
		input logic mem_write_en,
		
		input logic clk,
		input logic rst,
		
		input logic [31:0]address,
		input logic [31:0]write_data,
		
		output logic [31:0]read_data
	);
	
	
	logic [31:0]mem_reg[1023:0];
	logic mem_reg_x;
	
	
	assign read_data = mem_read_en ? 	mem_reg[(address[9:0])] 	: 		32'd0;
	
	always_ff @(posedge clk or negedge rst)
	begin
		
		integer i;
		if(!rst)
		begin
			for(i=0 ; i<1024 ; i=i+1)
			begin
				mem_reg[i] 				<= 		32'd0; 
			end
				mem_reg_x 				<= 		1'b0;
		end
		
		else
		begin
		
			if(mem_write_en)
			begin
				mem_reg[(address[9:0])] 	<= 		write_data; 
			end
				
			else
			begin
				mem_reg_x 					<= 		write_data;
			end
			
		end
	end
	
endmodule