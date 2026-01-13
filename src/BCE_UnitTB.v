module BCE_UnitTB;

    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] bf;
    wire bcres;

    BCE_Unit uut (
        .a(a),
        .b(b),
        .bf(bf),
        .bcres(bcres)
    );

    initial begin
        a = -5; b = 0; bf = 4'b0010; #100; // a < 0
        a = 10; b = 0; bf = 4'b0011; #100;  // a >= 0
        a = 42; b = 42; bf = 4'b1000; #100; // a == b
        a = 15; b = 15; bf = 4'b1010; #100; // a != b
        a = 0; bf = 4'b1100; #100;   // a <= 0
        a = 20; bf = 4'b1100; #100; // a <= 0
        a = 1; bf = 4'b1110; #100; // a > 0
        a = 0; bf = 4'b1110; #100; // a > 0 
        bf = 4'b1111; #100;                 

        $finish;
    end

endmodule

