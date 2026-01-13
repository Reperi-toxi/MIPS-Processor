module InstructionDecodertb;

reg [31:0] instruction;
wire RegWrite;
wire ALUSrc;
wire [1:0] ALUOp;
wire MemWrite;
wire MemRead;
wire Branch;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [15:0] immediate;
wire [5:0] funct;
wire [5:0] opcode;

instruction_decoder uut (
    .instruction(instruction),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .Branch(Branch),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .immediate(immediate),
    .funct(funct),
    .opcode(opcode)
);

initial begin    
    // ADD: rs=1, rt=2, rd=3, funct=100000
    instruction = 32'b000000_00001_00010_00011_00000_100000;
    #100;
    
    // SUB: rs=4, rt=5, rd=6, funct=100010
    instruction = 32'b000000_00100_00101_00110_00000_100010;
    #100;
    
    // AND: rs=7, rt=8, rd=9, funct=100100
    instruction = 32'b000000_00111_01000_01001_00000_100100;
    #100;
    
    // OR: rs=10, rt=11, rd=12, funct=100101
    instruction = 32'b000000_01010_01011_01100_00000_100101;
    #100;
    
    // ADDI: rs=1, rt=2, immediate=100
    instruction = 32'b001000_00001_00010_0000000001100100;
    #100;
    
    // ORI: rs=3, rt=4, immediate=255
    instruction = 32'b001101_00011_00100_0000000011111111;
    #100;
    
    // LW: rs=5, rt=6, immediate=20
    instruction = 32'b100011_00101_00110_0000000000010100;
    #100;
    
    // SW: rs=7, rt=8, immediate=24
    instruction = 32'b101011_00111_01000_0000000000011000;
    #100;
    
    // BEQ: rs=9, rt=10, immediate=16
    instruction = 32'b000100_01001_01010_0000000000010000;
    #100;
    
    // BNE: rs=11, rt=12, immediate=32
    instruction = 32'b000101_01011_01100_0000000000100000;
    #100;
    
    // LUI: rt=13, immediate=4096 (0x1000)
    instruction = 32'b001111_00000_01101_0001000000000000;
    #100;
    
    // Test unknown instruction
    instruction = 32'b111111_00000_00000_0000000000000000;
    #100;
    
    $finish;
end

endmodule