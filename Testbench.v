`timescale 1ns / 1ps
module tb;
integer i;
reg clk,rst;
reg [15:0]din;
wire [15:0]dout;

top dut(clk,rst,din,dout);         //instantiation of top module
initial begin
$monitor("clk=%b,rst=%b,din=%d,dout=%d",clk,rst,din,dout);
  
clk = 0;
rst = 1'b1;
din=0;
#10 rst=1'b0;
#20 din = 5;
#100 $finish;
end
always #5 clk = ~clk;
endmodule
