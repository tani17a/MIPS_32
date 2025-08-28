`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FILE NAME : MIPS_processor_32bit.v
// TYPE:    12: module 
// Module Name: MIPS32_pipe 
// Name: Microprocessor without Interlocked Pipeline Stages(MIPS)
// Description: NONE 
//
// Dependencies: NONE
// 
// Purpose: 32 bit 5 stages Pipelined MIPS processor with 26 instruction set and FLAG register
//          S,Z,X,X,X,P,X,CY and with 6 hardware intrrupts
// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module MIPS32_pipe(input clk1,clk2,[5:0] INTR);
// There are two clocks but instruction is fetched during the clk1 these are applied to prevent from the data hazard
  
 reg [31:0] PC,IF_ID_IR,IF_ID_NPC;
 reg [31:0] ID_EX_IR,ID_EX_NPC,ID_EX_A,ID_EX_B,ID_EX_Imm;
 reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
 reg [3:0] ID_EX_type,EX_MEM_type,MEM_WB_type; //For the type of instruction     
 reg EX_MEM_cond;//For BNEQ AND BEQZ
 reg [31:0] MEM_WB_IR,MEM_WB_ALUOut,MEM_WB_LMD;
 
 
 reg [31:0] Reg [0:31]; //Register bank of 32 register of 32 bits 
 reg [31:0] Mem [0:1023];// 1023 X 32 memory
  
// ALU operatoin parameters opcocodes
 parameter ADD=6'b000000,SUB=6'b000001,
   AND=6'b000010,
   OR=6'b000011,
	SLT=6'b000100,	//less than B
	MUL=6'b000101,
	LW=6'b001000,
	SW=6'b001001,ADDI=6'b001010,
	SUBI=6'b001011,
	SLTI=6'b000110,	//less than I
	BNEQZ=6'b001101,BEQZ=6'b001110,
	JUMP=6'b001111,	//included for JUMP
	ADC=6'b010000,ADCI=6'b010001,SUBB=6'b010010,
	MOV=6'b010011,MOVCC=6'b010100,MOVSC=6'b010101,MVI=6'b010110,
	CALL=6'b010111,
	RET=6'b011000,		//Return from the call 
	IRET=6'b011001,	//Return from the intrrupts
	HLT=6'b111111;                       												

//Type of instructions
 parameter RR_ALU=4'b0000, RM_ALU=4'b0001,
	LOAD=4'b0010,STORE=4'b0011,
	BRANCH=4'b0100,HALT=4'b0111 ,JUMP_T=4'b1000,
	RR=4'b1001;													
	
 reg HALTED;//Set after completion of HALT instruction
	
 reg TAKEN_BRANCH;//Disable instructions to write after branch
 
 //FOR THE FLAGS  S,Z,X,X,X,P,X,CY//////
 reg [7:0] FLAGS;
 reg [32:0] FULL_SUM,FULL_DIFF;
 reg [4:0] FIRST_NIBBLE;
 
 //FOR THE STACK
 reg [31:0]STACK [0:1023];
 integer TOP;
 integer i;
 
 //FOR INTRRUPTS
 reg IE_IF,IE_ID,IE_EX,IE_MEM,IE_WB; //Intrupts enable
 reg [31:0] EPC;	//Exception Program Counter
 reg [5:0] Cause_IP;  //1 bit per interrupt line stores the occured and pending intrrupt
 reg [7:0] S_FLAGS;	//store the original flags
 reg [5:0] INTR_ID; //stores id of intrrupt  performed
 
 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                           
 //                                                                     IF STAGE
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 always@(posedge clk1)begin
  //	Normal operations
  if(HALTED==0 )	//if Halted no instruction is fetched 
  begin
   if (((EX_MEM_IR[31:26] == BEQZ) &&(EX_MEM_cond == 1))||	//Check the branch and return the condition 
	    ((EX_MEM_IR[31:26] == BNEQZ) &&(EX_MEM_cond ==0))||
	    (EX_MEM_IR[31:26] == JUMP)||
	    (EX_MEM_IR[31:26] == CALL) ||(EX_MEM_IR[31:26] == RET) 	||
	    (EX_MEM_IR[31:26] == IRET)															
	    )
	 begin
	  IF_ID_IR <= #2 Mem[EX_MEM_ALUOut];
	  TAKEN_BRANCH <= #2 1'b1;              //so the instruction that were fetched do not write anything in mem due to branch
	  IF_ID_NPC <= #2 EX_MEM_ALUOut + 1;
	  PC <= #2 EX_MEM_ALUOut + 1;
	  if (EX_MEM_IR[31:26]==IRET) begin
	   IE_IF <= #2 0; //MASK OTHER INTRRUPTS
	 
	  end
	 end
	else 
	begin
	 IF_ID_IR <= #2 Mem[PC];
	 IF_ID_NPC <= #2 PC + 1;
	 PC <= #2 PC + 1;
	 TAKEN_BRANCH <= #2 1'b0;
	end
  end
  
 end
 
 
 //	FOR intrupts 
 always@(posedge clk1)begin
   if(Cause_IP != 0) begin //	If halted still takes intrrupts
  	 if (IE_IF ==0)begin    //When there is no current intrrupt
        //FOR THE INTRRUPTS ADDRESS
        // Pick highest-priority interrupt (lowest index has priority here)
       EPC <=#2 PC;
       casex (Cause_IP)
            6'b1xxxxx: begin PC <= #2 32'h00000080;  // interrupt vector 0
                        INTR_ID<= #2 6'b011111;
                        end
            6'b01xxxx: begin PC <= #2 32'h00000084;  // interrupt vector 1
                        INTR_ID<= #2 6'b101111;
                        end
            6'b001xxx: begin PC <= #2 32'h00000088;  // interrupt vector 2
                        INTR_ID<= #2 6'b110111;
                        end
            6'b0001xx: begin PC <= #2 32'h0000008C;  // interrupt vector 3
                        INTR_ID<= #2 6'b111011;
                        end
            6'b00001x: begin PC <= #2 32'h00000090;  // interrupt vector 4
                        INTR_ID<= #2 6'b111101;
                        end
            6'b000001: begin PC <= #2 32'h00000094;  // interrupt vector 5
                        INTR_ID<= #2 6'b111110;
                        end
        endcase
  		IE_IF	<= #2 1; //masked other intrrupts;
  	end
  end
 end
 
 
 //FOR pending INTRUPTS 
always@(posedge clk1 or posedge INTR[0] or posedge INTR[1] or posedge INTR[2] or posedge INTR[3] or posedge INTR[4] or posedge INTR[5] )begin
       Cause_IP = Cause_IP | INTR;   // latch new interrupts
  end

 
//Ror storing the registers
always@(posedge IE_WB)begin
    //storing all the registers in stack
  	   for (i=TOP+1; i<33+TOP ; i=i+1)begin
  		    STACK[i]<= #2 Reg[i-TOP-1];
  		    Reg[i-TOP-1]<=#2 32'hxxxxxxxx;
  	   end
  	   TOP <= #2 32+TOP;
end

//FOR STORING and retriving the FLAGS
always@(posedge IE_EX)begin
	   S_FLAGS=FLAGS;
end
always@(negedge IE_EX)begin
	   FLAGS=S_FLAGS;
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                   ID STAGE
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 always@(posedge clk2)begin
  if(HALTED==0)
  begin
   if (IF_ID_IR[25:21] == 5'b00000) ID_EX_A <= 0;//Reg 0 always contains 0
	else ID_EX_A <= #2 Reg[IF_ID_IR[25:21]]; //rs
	
	if (IF_ID_IR[20:16] == 5'b00000) ID_EX_B <= 0;//Reg 0 always contains 0
	else ID_EX_B <= #2 Reg[IF_ID_IR[20:16]]; //rt
	
	ID_EX_NPC <= #2 IF_ID_NPC;
	ID_EX_IR <= #2 IF_ID_IR;
	IE_ID <= #2 IE_IF;
	
  //opcode classification decide the type of the instruction 
  case(IF_ID_IR[31:26]) 
  
    ADD,SUB,AND,OR,SLT,MUL,ADC,SUBB: ID_EX_type <= #2 RR_ALU;
    MOV,MOVCC,MOVSC: ID_EX_type <= #2 RR;
	ADDI,SUBI,SLTI,ADCI,MVI: ID_EX_type <= #2 RM_ALU;
	LW: ID_EX_type <= #2 LOAD;
	SW: ID_EX_type <= #2 STORE;
	BEQZ,BNEQZ: ID_EX_type <= #2 BRANCH; 
	HLT: ID_EX_type <= #2 HALT;
	JUMP,CALL,RET,IRET: ID_EX_type <= #2 JUMP_T;	//FOR JUMP
	default: ID_EX_type <= #2 HALT; //INVALID operation
	
  endcase
  
   //sign extention
	if (ID_EX_type==JUMP_T)begin 
	 ID_EX_Imm <= #2 {{22{IF_ID_IR[9]}},{IF_ID_IR[9:0]}}; 
	end else begin
	 ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};
	end
 
  
  end
 end
 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //                                                                            EX STAGE
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 always@(posedge clk1)
 begin
  if (HALTED ==0 )
  begin
   EX_MEM_type <= #2 ID_EX_type;
	EX_MEM_IR <= #2 ID_EX_IR;
	case(ID_EX_type)
	
	 RR_ALU: begin
	  case(ID_EX_IR[31:26]) //OPCODE type  register to register
	   ADD: begin 
	   	 FULL_SUM<= #2 {1'b0,ID_EX_A} + {1'b0,ID_EX_B};
	   	 EX_MEM_ALUOut<=#2 ID_EX_A + ID_EX_B ; 
	   	end
	   ADC: begin 
	   	 FULL_SUM<= #2 {1'b0,ID_EX_A} + {1'b0,ID_EX_B}+ FLAGS[0];
	   	 EX_MEM_ALUOut<=#2 ID_EX_A + ID_EX_B + FLAGS[0]; 
	   	end
		SUB:begin 
			FULL_DIFF<= #2 {1'b0,ID_EX_A} - {1'b0,ID_EX_B};
			EX_MEM_ALUOut<=#2 ID_EX_A - ID_EX_B;
			end
		SUBB:begin 
			FULL_DIFF<= #2 {1'b0,ID_EX_A} - {1'b0,ID_EX_B}-FLAGS[0];
			EX_MEM_ALUOut<=#2 ID_EX_A - ID_EX_B - FLAGS[0];
			end
		AND: EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
		OR: EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
		SLT: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B;
		MUL:begin
		 FULL_SUM<= #2 {1'b0,ID_EX_A} * {1'b0,ID_EX_B};
		 EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
		 end
		default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
	  endcase
	 end
	 
	 RM_ALU: begin    //OPCODE type  register to memory
	  case(ID_EX_IR[31:26])
	   ADDI: begin 
	   		FULL_SUM <=  {1'b0,ID_EX_A} + {1'b0,ID_EX_Imm};
	   		EX_MEM_ALUOut<=#2 ID_EX_A + ID_EX_Imm; 
	   		end
	   ADCI: begin 
	   		FULL_SUM <= #2 {1'b0,ID_EX_A} + {1'b0,ID_EX_Imm}+FLAGS[0];
	   		EX_MEM_ALUOut<=#2 ID_EX_A + ID_EX_Imm+FLAGS[0]; 
	   		end
		SUBI: begin 
				FULL_DIFF <= #2 {1'b0,ID_EX_A} - {1'b0,ID_EX_Imm};
				EX_MEM_ALUOut<=#2 ID_EX_A - ID_EX_Imm; 
				end
		SLTI: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
	  	MVI:  EX_MEM_ALUOut <= #2 ID_EX_Imm;
		default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
	  endcase
	 end
	 
	 LOAD, STORE:begin  //OPCODE load and store
	  EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
	  EX_MEM_B <= #2 ID_EX_B;
	 end
	 
	 BRANCH: begin //OPCODE branch
	  EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
	  EX_MEM_cond <= #2 (ID_EX_A == 0);
	 end
	 
	 JUMP_T:begin	//JUMP OR BRANCH ,INTRUPTS etc.
	  case(ID_EX_IR[31:26])
	   JUMP: begin 
	   		EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm; 
	   		end
	   CALL: begin 
	   		EX_MEM_ALUOut <= #2 ID_EX_Imm;
	   		STACK[TOP+1]<= #2 ID_EX_NPC;
	   		TOP<= #2 TOP+1; 
	   		end
	   RET: begin 
	   		EX_MEM_ALUOut <= #2 STACK[TOP];
	   		STACK[TOP] <= #2 32'hxxxxxxxx;
	   		TOP<= #2 TOP-1;	        
	   		end
	   IRET: begin 
	   		EX_MEM_ALUOut <= #2 EPC ;
	   	    Cause_IP <= #2 Cause_IP & INTR_ID;     // Clear just that one bit remove the done intrrupt	
	   		for (i=TOP; i>=TOP-31 ; i=i-1)begin 	//Original registers
  		     Reg[31-TOP+i] <= #2 STACK[i];
  		    end  
  		    TOP<= #2 TOP-32; 
  		   // FLAGS<= #2 S_FLAGS; 
	   		end
		default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
	  endcase
	 end
	 
	 RR: begin
	 	case(ID_EX_IR[31:26])	
	 	  MOVCC: FLAGS[0]<=#2 0;  //CHANGE THE FLAGS NOT DONE SEPRATELY AS NO PARALLEL INSTRUCTIONS NEEDED
	 	  MOVSC: FLAGS[0]<=#2 1;  //WE DONT WANT TO CHANGE THE CARRY IF BOTH CASES ARE NOT HENCE NO DEFAULT CASE
	 	 endcase
	 	 EX_MEM_ALUOut<=#2 ID_EX_A ;
	 end
	endcase
   end
    IE_EX<= #2 IE_ID;
 end
 
 
 //FOR FLAGS AND STACK
 always@(posedge clk1)begin
	if (^EX_MEM_ALUOut === 1'bx) begin
            // Do nothing  FLAGS hold previous value
        end else if(((ID_EX_type==RM_ALU ) && ID_EX_IR[31:26]!=MVI )|| (ID_EX_type==RR_ALU)|| (ID_EX_type==RR) ) begin
            FLAGS[2] = ~(^EX_MEM_ALUOut);    // Parity
            FLAGS[6] =  (EX_MEM_ALUOut == 0); // Zero
            FLAGS[7] =  EX_MEM_ALUOut[31];    // Sign
            case(ID_EX_IR[31:26])   //CARRY
            ADD,ADC,ADDI,ADCI,MUL: 	FLAGS[0]= (FULL_SUM[32]==1)? 1:0;  //THERE IS NO DEFAULT CASE AS THE PREVIOUS VALUE OF THE CARRY SHOULD BE SAME IF NOT ANY OF THIS CASE
		    SUB,SUBB,SUBI: FLAGS[0]= (FULL_DIFF[32]==1)? 1:0;  
		    default: ;
	endcase
        end
 end
 

 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //                                                                 MEM STAGE
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 always@(posedge clk2) begin
  if (HALTED ==0)
  begin
   MEM_WB_type <= #2 EX_MEM_type;
	MEM_WB_IR <= #2 EX_MEM_IR;
	
	case(EX_MEM_type) // Type
	
	 RR_ALU, RM_ALU,RR: MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
	 LOAD: MEM_WB_LMD <= #2 Mem[EX_MEM_ALUOut];
	 RR: MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
	 STORE: if(TAKEN_BRANCH ==0 )	 // Disable write in memory
	           Mem[EX_MEM_ALUOut] <= EX_MEM_B;
	   
 	endcase
 	IE_MEM<= #2 IE_EX;
  end
 end
 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //                                                                 WR STAGE
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 always@(posedge clk1)begin
  if (TAKEN_BRANCH==0)
   case(MEM_WB_type)
	
	 RR_ALU: Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut;
	 RM_ALU: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut;
	 LOAD: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;
	 RR: Reg[MEM_WB_IR[20:16]]<= #2 MEM_WB_ALUOut;
	 HALT:HALTED <= #2 1'b1;
	endcase
	IE_WB<= #2 IE_MEM;
 end
 
 
endmodule
