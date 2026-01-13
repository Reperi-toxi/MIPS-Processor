module ShifterTB;

    reg [1:0] funct;
    reg [31:0] a;
    reg [4:0] N;
    wire [31:0] R;

    shifter uut (
        .funct(funct),
        .a(a),
        .N(N),
        .R(R)
    );

    initial begin
        funct = 2'b00; a = 32'h0000_F0F0; N = 5'd4; #10; // shift left logical
        funct = 2'b01; a = 32'hF000_0000; N = 5'd4; #10; // shift right logical
        funct = 2'b10; a = 32'hF000_0000; N = 5'd8; #10; // shift right logical
        funct = 2'b11; a = 32'h7000_0000; N = 5'd4; #10; // shift right arithmetic 
        funct = 2'b11; a = 32'hF000_0000; N = 5'd4; #10; // shift right arithmetic 
        funct = 2'b11; a = 32'hF000_0000; N = 5'd0; #10; // shift right arithmetic (zero shift)
        funct = 2'bxx; a = 32'hFFFF_FFFF; N = 5'd1; #10; 

        $finish;
    end

endmodule

