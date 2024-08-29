`define op_type IR[31:27]
`define rdst IR[26:22]
`define rsrc1 IR[21:17]
`define mode IR[16]
`define rsrc2 IR[15:11]
`define isrc IR[15:0]
///////////////////////
`define movsgpr 5'b00000       ////for moving special gpr of multiplication op
`define mov   5'b00001
`define add   5'b00010
`define sub   5'b00011
`define mul   5'b00100

//////////////////////////
//Logical OP
////////////////////////
`define ror   5'b00101
`define rand  5'b00110
`define rnot  5'b00111
`define rnand 5'b01000
`define rnor  5'b01001
`define rxor  5'b01010
`define rxnor 5'b01011


`define storereg 5'b01100  ///register content to data mem
`define storedin 5'b01101  // din bus content to data_mem
`define send2dout 5'b01110 //data mem to dout bus
`define send2reg 5'b01111  //data mem to register

////////////////////////////jump instructions
`define jump 5'b10010
`define jcarry 5'b10011
`define jnocarry 5'b10100
`define jsign 5'b10101
`define jnosign 5'b10110
`define jzero 5'b10111
`define jnozero 5'b11000
`define joverflow 5'b11001
`define jnooverflow 5'b11010

////////////////////////hult
`define halt 5'b11011


module top(
input clk,rst,
input [15:0]din,
output reg [15:0]dout
);
 reg [31:0]IR;  
 reg [15:0]GPR[31:0];
 
 reg [15:0]SGPR;
 reg [31:0]mul_res;
 
 ////////////////////
 reg [31:0]inst_mem[15:0];///program memory
 reg [15:0] data_mem[15:0];////data memory
 
 /////////flags
 reg zero=0,sign=0,carry=0,overflow=0;
 reg [16:0]tmp_sum;
 
 
 reg jmp_flag = 0;
 reg stop = 0;
 
 task decode_inst();
 begin
 
 jmp_flag = 0;
 stop = 0;
 
 case(`op_type)
 `movsgpr: 
    GPR[`rdst] = SGPR;
 
 `mov:begin
    if(`mode)
        GPR[`rdst] = `isrc;            //////////mode 1 means immediate addressing mode
    else
        GPR[`rdst] = GPR[`rsrc1];
 end
 
 `add: begin
    if(`mode)
        GPR[`rdst] = GPR[`rsrc1] + `isrc; 
    else
        GPR[`rdst] = GPR[`rsrc1] + GPR[`rsrc2]; 
 end
 
 `sub:begin
    if(`mode)
        GPR[`rdst] = GPR[`rsrc1] - `isrc; 
    else
        GPR[`rdst] = GPR[`rsrc1] - GPR[`rsrc2]; 
 end
 
 `mul:begin 
    if(`mode)
        mul_res = GPR[`rsrc1] * `isrc; 
    else
        mul_res = GPR[`rsrc1] * GPR[`rsrc2];
        
    GPR[`rdst] = mul_res[15:0];
    SGPR = mul_res[31:16]; 
 end
 
 `ror:begin
    if(`mode)
         GPR[`rdst] = GPR[`rsrc1] | `isrc;
    else
        GPR[`rdst] = GPR[`rsrc1] | GPR[`rsrc2];
 end
 
 `rand:begin
    if(`mode)
         GPR[`rdst] = GPR[`rsrc1] & `isrc;
    else
        GPR[`rdst] = GPR[`rsrc1] & GPR[`rsrc2];
 end
 
 `rnot:begin
    if(`mode)
         GPR[`rdst] = ~`isrc;
    else
        GPR[`rdst] = ~GPR[`rsrc1];
 end
 
 `rnand:begin
    if(`mode)
        GPR[`rdst] = ~(GPR[`rsrc1] & `isrc);
    else
        GPR[`rdst] = ~(GPR[`rsrc1] & GPR[`rsrc2]);
 end
 
 `rnor:begin
    if(`mode)
         GPR[`rdst] = ~(GPR[`rsrc1] | `isrc);
    else
        GPR[`rdst] = ~(GPR[`rsrc1] | GPR[`rsrc2]);
 end
 
 `rxor:begin
    if(`mode)
         GPR[`rdst] = GPR[`rsrc1] ^ `isrc;
    else
        GPR[`rdst] = GPR[`rsrc1] ^ GPR[`rsrc2];
 end
 
 `rxnor:begin
    if(`mode)
         GPR[`rdst] = GPR[`rsrc1] ~^ `isrc;
    else
        GPR[`rdst] = GPR[`rsrc1] ~^ GPR[`rsrc2];
 end
  /////////////////////////////////////////////////
 ////data_instructions
 ////////////////////////////////////////////////
 `storedin:
    data_mem[`isrc] = din;
  
 `storereg:
    data_mem[`isrc] = GPR[`rsrc1];
    
 `send2reg:
    GPR[`rdst] = data_mem[`isrc];
    
 `send2dout:
    dout = data_mem[`isrc];  
    
  //////////////////jump conditions 
 `jump:
    jmp_flag = 1;
       
  `jcarry:begin
    if(carry == 1)
        jmp_flag = 1;
    else
        jmp_flag = 0;
  end
  
  `jnocarry:begin
    if(carry == 0)
        jmp_flag = 1;
    else
        jmp_flag = 0;
  end
  
  `jzero:begin
    if(zero==1)
        jmp_flag = 1;
    else
        jmp_flag = 0; 
   end
  
  `jnozero:begin
    if(zero==1)
        jmp_flag = 0;
    else
        jmp_flag = 1;
  end
  
  `jsign:begin
    if(sign==1)
        jmp_flag = 1;
    else
        jmp_flag = 0;
  end    

  `jnosign:begin
    if(sign==0)
        jmp_flag = 1;
    else
        jmp_flag = 0;
  end
        
  `joverflow:begin
    if(overflow==1)
        jmp_flag = 1;
    else
        jmp_flag = 0;
  end

  `jnooverflow:begin
    if(overflow==0)
        jmp_flag = 1;
    else
        jmp_flag = 0;
  end
  
  `halt:
    stop = 1;
    
 endcase
 end
 endtask
 
 
 /////////////////////////
 //Logical Unit
 ////////////////////////////
 
 /////////condition flag
 
 task decode_condflag();
 begin
 /////////////sign flag
 if(`op_type == `mul)
    sign = SGPR[15];
 else
    sign = GPR[`rdst][15];
 //////////////carry flag
 
 if(`op_type == `add)begin
    if(`mode)begin
        tmp_sum = GPR[`rsrc1] + `isrc;
        carry= tmp_sum[16];
        end
    else begin
        tmp_sum = GPR[`rsrc1] + GPR[`rsrc2];
        carry= tmp_sum[16];
        end 
    end 
  else 
    carry = 1'b0;
    
 
 ///////zero bit
 
 //zero =  ( ~(|GPR[`rdst]) ~(|SGPR[15:0])); 
 
 if (`op_type == `mul)
	zero = ~((|SGPR[15]) | (|GPR[`rdst]));
 else
	zero = ~(|GPR[`rdst]);
 
    
 //////////////////overflow flag
 
 if (`op_type ==`add) begin
    if(`mode)
        overflow = (~GPR[`rsrc1][15] & ~IR[15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & IR[15] & ~GPR[`rdst][15]);              ////as IR[15:0] = isrc 
    else
        overflow = (~GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & GPR[`rsrc2][15] & ~GPR[`rdst][15]);
 end
 
 else if(`op_type==`sub)begin
    if(`mode)
        overflow = (~GPR[`rsrc1][15] & IR[15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & ~IR[15] & ~GPR[`rdst][15]);              ////as IR[15:0] = isrc 
    else
        overflow = (~GPR[`rsrc1][15] & GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & ~GPR[`rdst][15]);
 end
 else
    overflow = 1'b0;
 end
 endtask
 //////////////////////////
 
 initial begin
 $readmemb("inst_data.mem",inst_mem);
 ///////reading instructions from memory file
 end
 
 integer pc = 0;
 reg [2:0]count=0;
 
 always @(posedge clk) begin
 if(rst)begin
    pc <= 0;
    count <= 0;
 end
 else begin
    if (count<4)
        count<=count+1;
    else begin
        count<=0;
        pc<=pc+1;
    end
 end
 end
 
 always @(*)begin
 if(rst)
    IR =0;
 else begin
    IR=inst_mem[pc];
    decode_inst();
    decode_condflag();
 end
 end
 /////////////////////////////////////////
 /////////////////////////////////////
 parameter idle=0,fetch=1,decode_exec=2,next_inst=3,sense_halt=4,
    delay_next_inst=5;
    
 
 reg[2:0] state = idle;
 reg next_state=idle;
 
 always @(posedge clk)begin
 if(rst)
    state <= idle;
 else
    state <= next_state;
 end
 
 always @(*)begin
 case(state)
  idle : begin
    IR = 32'h0;
    pc = 0;
    next_state = fetch;
  end
  
  fetch:begin
    IR = inst_mem[pc];
    next_state = decode_exec;
  end
  
  decode_exec:begin
    decode_inst();
    decode_condflag();
    next_state = delay_next_inst;
 end
 
 delay_next_inst:begin
    if(count<4)
        next_state = delay_next_inst;
    else
        next_state = next_inst;
 end      
 
 next_inst:begin
    next_state = sense_halt;
    if(jmp_flag == 1)
        pc = `isrc;
    else
        pc = pc + 1;
 end
        
 sense_halt:begin
    if (!stop)
        next_state = fetch; 
    else if (rst)
        next_state = idle;
    else
        next_state = sense_halt;
 end
 
 default: next_state = idle;
 endcase
 end
 
 ////////////////////////////////////////count update
 
 always @(posedge clk)begin
 case(state)
    idle: count <= 0;
    
    fetch: count<=0;
    
    decode_exec: count<=0;
    
    delay_next_inst: count <= count+1;
    
    next_inst: count<=0;
    
    sense_halt: count<=0;
    
    default: count<=0;
 endcase
 end 
endmodule
