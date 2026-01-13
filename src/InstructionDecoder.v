module instruction_decoder(
    input [31:0] instruction,
    output reg RegWrite,
    output reg ALUSrc, //reg or imm
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg MemRead,
    output reg Branch,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [15:0] immediate,
    output [5:0] funct,
    output [5:0] opcode
);
// Fields
assign opcode    = instruction[31:26];
assign rs        = instruction[25:21];
assign rt        = instruction[20:16];
assign rd        = instruction[15:11];
assign immediate = instruction[15:0];
assign funct     = instruction[5:0];
always @(*) begin
    // default 
    RegWrite = 0;
    ALUSrc   = 0;
    ALUOp    = 2'b00;
    MemWrite = 0;
    MemRead  = 0;
    Branch   = 0;

    case (opcode)
        6'b000000: begin // R-type 
            RegWrite = 1;
            ALUSrc   = 0;
            MemWrite = 0;
            MemRead  = 0;
            Branch   = 0;
            case (funct)
                6'b100000: ALUOp = 2'b10; // add
                6'b100010: ALUOp = 2'b10; // sub  
                6'b100100: ALUOp = 2'b10; // and
                6'b100101: ALUOp = 2'b10; // or
                default:   ALUOp = 2'b00; // unknown
            endcase
        end

        6'b001000: begin // addi 
            RegWrite = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b00; 
            MemWrite = 0;
            MemRead  = 0;
            Branch   = 0;
        end

        6'b001101: begin // ori 
            RegWrite = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b11; 
            MemWrite = 0;
            MemRead  = 0;
            Branch   = 0;
        end

        6'b100011: begin // lw (load word)
            RegWrite = 1;
            ALUSrc   = 1;
            MemRead  = 1;
            ALUOp    = 2'b00; 
            MemWrite = 0;
            Branch   = 0;
        end

        6'b101011: begin // sw 
            RegWrite = 0;     
            ALUSrc   = 1;      
            MemWrite = 1;
            ALUOp    = 2'b00; 
            MemRead  = 0;
            Branch   = 0;
        end

        6'b000100: begin // beq
            RegWrite = 0;
            ALUSrc   = 0;      
            Branch   = 1;
            ALUOp    = 2'b01;  
            MemWrite = 0;
            MemRead  = 0;
        end

        6'b000101: begin // bne 
            RegWrite = 0;
            ALUSrc   = 0;
            Branch   = 1;
            ALUOp    = 2'b01;  
            MemWrite = 0;
            MemRead  = 0;
        end

        6'b001111: begin // lui 
            RegWrite = 1;
            ALUSrc   = 1;      
            ALUOp    = 2'b11;  // special lui operation in ALU
            MemWrite = 0;
            MemRead  = 0;
            Branch   = 0;
        end

        default: begin 
            RegWrite = 0;
            ALUSrc   = 0;
            ALUOp    = 2'b00;
            MemWrite = 0;
            MemRead  = 0;
            Branch   = 0;
        end
    endcase
end
endmodule