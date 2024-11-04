module processor_top_tb;

  logic clk = 1'b0;
  logic rst;

  processor_top tb(
    .clk(clk),
    .rst(rst)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;  
  end


  initial begin
    rst = 0;
    #6;  
    
    rst = 1;
    #30;   
    
    $finish;
    
  end
    
endmodule
