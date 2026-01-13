module ALU_Control (
    input wire [1:0] ALUOp,
    input wire [5:0] funct,
    input wire [5:0] opcode,
    output reg [3:0] ALU_Control
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALU_Control = 4'b0000; // ADD (for lw, sw, addi)
            2'b01: ALU_Control = 4'b0010; // SUB (for branch)
            2'b10: begin // R-type instructions
                case (funct)
                    6'b100000: ALU_Control = 4'b0000; // add
                    6'b100010: ALU_Control = 4'b0010; // sub
                    6'b100100: ALU_Control = 4'b0100; // and
                    6'b100101: ALU_Control = 4'b0101; // or
                    6'b101010: ALU_Control = 4'b1010; // slt
                    default:   ALU_Control = 4'b0000; // default to add
                endcase
            end
            2'b11: begin // Special operations
                if (opcode == 6'b001101) // ori
                    ALU_Control = 4'b0101; // OR
                else if (opcode == 6'b001111) // lui
                    ALU_Control = 4'b0101; // OR (special handling needed)
                else
                    ALU_Control = 4'b0000;
            end
            default: ALU_Control = 4'b0000;
        endcase
    end
endmodule