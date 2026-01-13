module RegisterFiletb;
  reg clk;
  reg rst;
  reg WR;
  reg RD;
  reg [3:0] Sel_i1;
  reg [3:0] Sel_o1;
  reg [3:0] Sel_o2;
  reg [31:0] Ip1;

  wire [31:0] Op1;
  wire [31:0] Op2;
  
  RegisterFile uut (
    .clk(clk),
    .rst(rst),
    .WR(WR),
    .RD(RD),
    .Sel_i1(Sel_i1),
    .Sel_o1(Sel_o1),
    .Sel_o2(Sel_o2),
    .Ip1(Ip1),
    .Op1(Op1),
    .Op2(Op2)
  );

  // Clock 
  always #50 clk = ~clk;

  initial begin
    clk = 0; rst = 1;
    WR = 0;RD = 0;
    Sel_i1 = 0; Sel_o1 = 0; Sel_o2 = 0;
    Ip1 = 0;
	 #100 rst = 0;
	 //writing to register 2
	 WR = 1;
	 Sel_i1 = 4'd2;
	 Ip1 = 32'hAAAA_BBBB;
	 #100 WR = 0;
	 //writing to register 5
	 WR = 1;
	 Sel_i1 = 4'd5;
	 Ip1 = 32'h1234_5678;
	 #100 WR = 0;
	 
	 //reading from resgisters 2 and 5
	 RD = 1;
	 Sel_o1 = 4'd2;
	 Sel_o2 = 4'd5;
	 #100 RD = 0;
	 $finish;
	 end 
endmodule	 
	 