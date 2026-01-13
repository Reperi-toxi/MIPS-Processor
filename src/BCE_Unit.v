module BCE_Unit (
    input  wire [31:0] a,
    input  wire [31:0] b,      
    input  wire [3:0]  bf,     
    output reg bcres
);

   always @(*) begin
      case (bf)
          4'b0010: bcres = ($signed(a) <  0);
          4'b0011: bcres = ($signed(a) >= 0);
          4'b1000: bcres = (a == b);
          4'b1010: bcres = (a != b);
          4'b1100: bcres = ($signed(a) <= 0);
          4'b1110: bcres = ($signed(a) >  0);
		 default: bcres = 1'b0;
     endcase
    end

endmodule

