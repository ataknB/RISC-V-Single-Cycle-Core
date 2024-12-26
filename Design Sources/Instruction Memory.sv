module Instruction_Memory #(
parameter InstLength = 256,
parameter IMemInitFile = "imem.mem" 
    )(
    input  logic [31:0]Program_counter_IM,
    output  logic [31:0]Instruction_IM
    //TRAP HANDLING
	/*
    output reg exception_flag_IM,
    output reg [31:0] exception_cause_IM,
    output reg [31:0] exception_value_IM
	
	*/
    );
   
    logic [31:0]Instraction_Memory[InstLength-1:0];
    initial begin
    $readmemh("imem.mem", Instraction_Memory);
    end
    
	assign Instruction_IM = Instraction_Memory[{2'd0 , Program_counter_IM[31:2]}];
	
	
endmodule


