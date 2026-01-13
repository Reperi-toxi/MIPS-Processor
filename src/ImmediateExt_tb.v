module ImmediateExt_tb;
    parameter N = 16;
    parameter M = 32;
	 
    reg clk;
    reg [N-1:0] immediateIN;
    reg U;
	 
    wire [M-1:0] immediateOUT;

    ImmediateExt #(N, M) uut (
        .clk(clk),
        .immediateIN(immediateIN),
        .U(U),
        .immediateOUT(immediateOUT)
    );
    initial clk = 0;
    always #50 clk = ~clk;

    initial begin
        U = 1;
        immediateIN = 16'b0001001000110100;
        #100;
        immediateIN = 16'b1111001000110100; 
        #100;
        U = 0;
        immediateIN = 16'b0001001000110100; 
        #100;
        immediateIN = 16'b1111001000110100; 
        #100;
        $finish;
    end
endmodule
