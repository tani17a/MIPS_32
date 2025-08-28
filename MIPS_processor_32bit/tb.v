`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2025 07:58:36 PM
// Design Name: 
// Module Name: tb
// Project Name: MIPS32
// Target Devices: 
// Tool Versions: 
// Description: Test bench for MIPS 32 PROCESSOR
// 
// Dependencies: NO
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb();
			reg clk1;
			reg clk2;
			integer k;
			reg [5:0] intr;
			
			MIPS32_pipe mips (clk1, clk2,intr);
			
			
			initial begin
				clk1=0;
				clk2=0;
				intr=0;
				repeat(30)begin
					#5 clk1=1; #5 clk2=0;
					#5 clk2=1; #5 clk1=0;
				end 
			end
			
			
			//For intruupts
	/*		initial begin
			     intr=0;
			     #20 intr= 6'b010000;
			     intr= #20 0;
			end */
						
			initial begin
				for (k=0; k<32; k=k+1)begin
					mips.Reg[k]=k;
				end
				
			    mips.HALTED=0;
                mips.PC=0;
                mips.TAKEN_BRANCH=0;
                mips.FLAGS=128;
                mips.S_FLAGS=0;
                mips.TOP=-1;
                mips.IE_IF=0;
                mips.Cause_IP=0; 
                
            //in hexadecimal
				//Examples 
				mips.Mem[0]=32'h58010055;   //MVI, R1,55  R1=55H
				mips.Mem[1]=32'h0ce77800;   //OR R7, R7 ,R7
				mips.Mem[2]=32'h4C220000;   //MOV R2, R1  R2=55H
				mips.Mem[3]=32'h0ce77800;   //OR R7, R7 ,R7
				mips.Mem[4]=32'h00221800;   //ADD R3,R1,R2 R3=AA
				mips.Mem[5]=32'h28240020;   //ADDI R4,R1,20H R4=75
				mips.Mem[6]=32'h0ce77800;   //OR R7, R7 ,R7
				mips.Mem[7]=32'h40832800;   //ADC R5,R4,R3 R5=11F
				mips.Mem[8]=32'h0ce77800;   //OR R7, R7 ,R7
				mips.Mem[9]=32'h14a53000;   //MUL R6,R5,R5 R6=141c1
				mips.Mem[10]=32'h0ce77800;   //OR R7, R7 ,R7
				mips.Mem[11]=32'h14c63800;   //MUL R7,R6,R6 R7=194659381
				mips.Mem[12]=32'h0ce77800;   //OR R7, R7 ,R7
				mips.Mem[13]=32'h40832800;   //ADC R5,R4,R3 R5=120
				mips.Mem[14]=32'h246a0025;   //SW R3,25H(R10) MEM[25+R3=CF]<-REG[R10]=a
				mips.Mem[15]=32'h0ce77800;   //OR R7, R7 ,R7
				mips.Mem[16]=32'h20620025;   //LW R2,25H(R3) R2<-Mem[25+R3=CF] R2=a
				mips.Mem[17]=32'h10460800;   //SLT R1, R2 ,R6  R1<-R2<R6  R1=1
				mips.Mem[18]=32'h18C200aa;   //SLTI R2, R6 ,AAH  R1<-R6<AA R2=0
				
				
				
				
				//in decimal
//				mips.Mem[0]=32'h2801000a;   //ADDI R1, R0,10  R1=10
//				mips.Mem[1]=32'h28020014;   //ADDI R2, R0,20  R2=20
//				mips.Mem[2]=32'h28030019;	//ADDI R3, R0,25  R3=25
//				mips.Mem[4]=32'h0ce77800;   //OR R7, R7 ,R7 
//				mips.Mem[5]=32'h3c000002;   //JUMP Loop
//				mips.Mem[6]=32'h00222000;   // ADD R4, R1, R2 R4=30
//				mips.Mem[7]=32'h0ce77800;	//OR R7, R7, R7
//				mips.Mem[8]=32'h00832800;	// Loop:ADD R5, R4, R3 R5=29
//				mips.Mem[9]=32'hfc000000;   //HLT
            
               
               
              /*
               //FOR CALL INSTRUCTION 
 
                mips.Mem[0]=32'h2801000a;   //ADDI R1, R0,10  R1=10
				mips.Mem[1]=32'h28020014;   //ADDI R2, R0,20  R2=20
				mips.Mem[2]=32'h28030019;	//ADDI R3, R0,25  R3=25=19H
				mips.Mem[3]=32'h0ce77800;   //OR R7 R7 ,R7
				mips.Mem[4]=32'h0ce77800;   //OR R7, R7 ,R7 
				mips.Mem[5]=32'h5C000010;   //CALL 16 
				mips.Mem[6]=32'h00842000;   //ADD R4, R4, R4 R4=8
				mips.Mem[7]=32'h0ce77800;	//OR R7, R7, R7
				mips.Mem[8]=32'h00832800;	// Loop:ADD R5, R4, R3 R5=21
				mips.Mem[9]=32'hfc000000;   //HLT
				
				//16 
				mips.Mem[16]=32'h246a0025;   //SW R3,25H(R10) MEM[25+R3=62]<-REG[R10]=a
				mips.Mem[17]=32'h0ce77800;    //OR R7, R7 ,R7 
				mips.Mem[18]=32'h20620025;   //LW R2,25H(R3) R2<-Mem[25+R3=3EH=62] R2=a
				mips.Mem[19]=32'h10460800;   //SLT R1, R2 ,R6  R1<-R2<R6  R1=0
				mips.Mem[20]=32'h18C200aa;   //SLTI R2, R6 ,AAH  R1<-R6<AA R2=1
                mips.Mem[21]=32'h60000000;   //RET
              */
              
             
            /*    
            //intruupts   
            mips.Mem[132]=32'h58010055;   //MVI, R1,55  R1=55H=85
				mips.Mem[133]=32'h0ce77800;   //OR R7, R7 ,R7
				mips.Mem[134]=32'h4C220000;   //MOV R2, R1  R2=55H=85
				mips.Mem[135]=32'h0ce77800;	 //OR R7, R7, R7     //ENSURES THAT THE PROCESS IS COMPLETE
            mips.Mem[136]=32'h64000000;   //IRET
            */
                
            mips.Mem[40]=32'h0000000a;
             
             #680;
             
             for (k=0; k<8; k=k+1) begin
                 $display("R%1d - %2d",k, mips.Reg[k]);
             end
             $display("%b", mips.FLAGS);
            // $display("%h",mips.Mem[207]);
            //$display("%h",mips.Mem[40]);
             
             
		end
			
			
			initial begin
				$dumpfile("mips.vcd");
				$dumpvars(0,tb);
				//#450 $finish;
				//#300 $finish;
				#700 $finish;
			end
			
endmodule
