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
  initial begin
    rst = 0;
    #2;  
    
    rst = 1;
    #10;   
    
    $finish;
  end

  // Dump PC, Instruction, and Register File
  initial begin
    forever @(posedge clk) begin
      $display("=== Processor State at time %0t ===", $time);
      
      // Program Counter
      $display("PC = %h", tb.PC_out);
      $display("RD = %d", tb.rd);
      $display("Instruciton = %h", tb.instructionMemory_out);

      // Instruction
      $display("Immediate value = %h", tb.imm);

      // Register File Contents
      for (int i = 0; i < 32; i++) begin
        $display("R[%0d] = %h", i, tb.RF_.reg_data[i]);
      end

      $display("==============================");
    end
  end

endmodule
