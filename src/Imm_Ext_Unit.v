module ImmediateExt #(parameter N = 16, M = 32)(
    input  wire clk,       
    input  wire [N-1:0] immediateIN,    
    input  wire U,  // 1 - zeroExt, 0 - signExt       
    output reg  [M-1:0] immediateOUT 
);

    always @(*) begin
        if (U == 1'b1) begin          
           immediateOUT <= {{(M-N){1'b0}}, immediateIN}; //zero ext
        end else begin
           immediateOUT <= {{(M-N){immediateIN[N-1]}}, immediateIN}; //sign ext
        end
    end

endmodule
