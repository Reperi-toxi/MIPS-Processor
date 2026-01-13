module shifter (
    input  wire [1:0]  funct,  
    input  wire [31:0] a,      
    input  wire [4:0]  N,      
    output reg  [31:0] R       
);
    always @(*) begin
        case (funct)
            2'b00: R = a << N;                                    // sll - shift left logical
            2'b01: R = a >> N;                                    // srl - shift right logical
            2'b10: R = 32'b0;                                     // unused - output zero
            2'b11: begin                                          // sra - shift right arithmetic
                if (N == 5'b0)
                    R = a;
                else
                    R = ({32{a[31]}} << (6'd32 - {1'b0, N})) | (a >> N);
            end
            default: R = 32'b0;
        endcase
    end
endmodule