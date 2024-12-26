`timescale 1ns / 1ps

module Shifter(
    input sra,
    input sll,
	/************** Functions ************ 
          sra_i  |  sll_i
    ----------------------    
    SRL |   0    |    0
    SLL |   0    |    1
    SRA |   1    |    0
    N/A |   1    |    1       // will pad 1s during left shift
****************************************/
	
    input [4:0]size,
    input [31:0]in,
    
    output [31:0]out
	);
    genvar m;
    genvar i;
    
    wire wireMSB;
    assign wireMSB = (sra) ? in[31] : 1'b0;
    
    //Wire Decleration
    generate
		genvar x;
		for (x=0; x<4; x=x+1) 
		begin: stage
			wire [31:0] wireCon;
		end
    endgenerate 
    
    
    generate
		genvar y;
		for (y=0; y<2; y=y+1) 
		begin: SLStage
			wire [31:0] wireCon;
		end
    endgenerate
    



//SLL 1
    generate 
        for(i=0;i<32;i=i+1)begin 
            assign SLStage[0].wireCon[31-i]= (sll) ? in[i]:in[31-i];
        end
    endgenerate 
    
    
    
//Big Circiut    


    generate 
        for(i=0;i<16;i=i+1)begin 
            assign stage[0].wireCon[31-i]= (size[4]) ? wireMSB : SLStage[0].wireCon[31-i];end
    endgenerate
    
    generate 
        for(i=0;i<16;i=i+1)begin 
            assign stage[0].wireCon[15-i]=(size[4]) ? SLStage[0].wireCon[31-i] : SLStage[0].wireCon[15-i];end
    endgenerate
    
    
    
    //////////////////////////////
    generate 
        for(i=0;i<8;i=i+1)begin 
            assign stage[1].wireCon[31-i]=(size[3]) ? wireMSB: stage[0].wireCon[31-i];end
    endgenerate
    
    generate 
        for(i=0;i<24;i=i+1)begin 
            assign stage[1].wireCon[23-i]=(size[3]) ? stage[0].wireCon[31-i] : stage[0].wireCon[23-i];end
    endgenerate
    //////////////////////////////
    generate 
        for(i=0;i<4;i=i+1)begin 
            assign stage[2].wireCon[31-i]=(size[2]) ? wireMSB: stage[1].wireCon[31-i];end
    endgenerate
    
    generate 
        for(i=0;i<28;i=i+1)begin 
            assign stage[2].wireCon[27-i]=(size[2]) ? stage[1].wireCon[31-i] : stage[1].wireCon[27-i];end
    endgenerate
    
    //////////////////////////////
    generate 
        for(i=0;i<2;i=i+1)begin 
            assign stage[3].wireCon[31-i]=(size[1]) ? wireMSB: stage[2].wireCon[31-i];end
    endgenerate
    
    generate 
        for(i=0;i<30;i=i+1)begin 
            assign stage[3].wireCon[29-i]=(size[1]) ? stage[2].wireCon[31-i] : stage[2].wireCon[29-i];end
    endgenerate
    
    
    
    
    
    
    
    
    //////////////////////////////
    
    assign SLStage[1].wireCon[31]=(size[0]) ? wireMSB : stage[3].wireCon[31];
    
    generate 
        for(i=0;i<31;i=i+1)begin 
            assign SLStage[1].wireCon[30-i]=(size[0]) ? stage[3].wireCon[31-i] : stage[3].wireCon[30-i];
        end
    endgenerate 
    
    
    //////////////////////////////
    
    generate 
        for(i=0;i<32;i=i+1)begin 
            assign out[31-i]=(sll) ? SLStage[1].wireCon[i] : SLStage[1].wireCon[31-i];
        end
    endgenerate 
    
    
    
endmodule
