module MIPS_ProcessorTB;
    reg clk;
    reg rst;

    wire [31:0] aluresout;
    wire [31:0] shift_resultout;
    wire [31:0] GP_DATA_INout;

    MIPS_Processor uut (
        .clk(clk),
        .rst(rst),
        .aluresout(aluresout),
        .shift_resultout(shift_resultout),
        .GP_DATA_INout(GP_DATA_INout)
    );
    always #5 clk = ~clk; 

    initial begin
        clk = 0;
        rst = 1;
        // Reset pulse
        #10;
        rst = 0;
        #200;
		 //we run the following commands: 
		 // addi $1, $0, 5 - Load 5 into $1
		 // addi $2, $0, 3 - Load 3 into $2  
		 // add $3, $1, $2 - Add $1 and $2, store in $3
		 // sll $2, $2, 2 - shift number in $2 by 2
		 // sw $1, 20($0) - Store $1 to memory address 20
		 // lw $3, 20($0) - Load from the memory address 20 into $3
       // addi $1, $0, 1 - Load 1 into $1
		 // j 0 - Jump to address 0 (loop)
        $finish;
    end
endmodule
