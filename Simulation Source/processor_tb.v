module processor_top_tb;

  logic clk = 1'b0;
  logic rst;

  // Instance of the processor_top module
  processor_top tb(
    .clk(clk),
    .rst(rst)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  
  end

  // Reset signal
  initial 
  begin
    rst = 1;
    #1;  
    
    rst = 0;
    #1;

    rst = 1;
    #1000;   
    
    $finish();
  end
  
endmodule
