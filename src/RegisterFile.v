module RegisterFile ( 
    input clk,
    input rst,
    input WR,
    input RD,
    input [4:0] Sel_i1,      
    input [4:0] Sel_o1,      
    input [4:0] Sel_o2,      
    input [31:0] Ip1,
    output reg [31:0] Op1,
    output reg [31:0] Op2
);    
    reg [31:0] regfile [31:0];  // Changed from [15:0] to [31:0] for 32 registers
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin //reset
            for(i=0; i < 32; i = i+1)  // Changed from 16 to 32
                regfile[i] <= 32'b0;
        end
        else begin 
            //write - but never write to register $0
            if(WR && (Sel_i1 != 5'b0))
                regfile[Sel_i1] <= Ip1;
        end
    end
    
    // Continuous reading (combinational logic)
    always @(*) begin
        if(RD) begin
            // Register $0 always reads as zero
            Op1 = (Sel_o1 == 5'b0) ? 32'b0 : regfile[Sel_o1];
            Op2 = (Sel_o2 == 5'b0) ? 32'b0 : regfile[Sel_o2];
        end else begin
            Op1 = 32'b0;
            Op2 = 32'b0;
        end
    end
endmodule