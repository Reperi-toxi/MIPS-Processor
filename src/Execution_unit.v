module execution_unit (
    input clk,
    input rst,
    input [31:0] instruction,
    output [31:0] alu_result,
    output [31:0] mem_out
);
    // Wires and registers
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd;
    wire [15:0] imm;
    wire RegWrite, ALUSrc, MemWrite, MemRead, Branch;
    wire [1:0] ALUOp;
    wire [31:0] reg_out1, reg_out2, alu_srcB, alu_res;
    wire [3:0] alu_ctrl;
    wire zero_flag, neg_flag, ovfalu_flag;
    wire signed [31:0] sign_ext_imm;
    reg [31:0] PC;
    reg [31:0] memory [0:255];
    wire [3:0] write_reg;
    
    // Sign-extension
    assign sign_ext_imm = {{16{imm[15]}}, imm};

    // ALU control signal 
    assign alu_ctrl = (ALUOp == 2'b00) ? 4'b0010 : // add/addi
                      (ALUOp == 2'b01) ? 4'b0110 : // SUB for branch
                      (ALUOp == 2'b11 && opcode == 6'b001101) ? 4'b0001 : // ori
                      (ALUOp == 2'b11 && opcode == 6'b001111) ? 4'b1000 : // lui 
                      4'b0000; // default AND for now
    
    assign write_reg = (opcode == 6'b000000) ? rd[3:0] : rt[3:0]; // R-type or I-type dest

    // Modules
    instruction_decoder decoder(
        .instruction(instruction),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .Branch(Branch),
        .rs(rs), .rt(rt), .rd(rd),
        .immediate(imm),
        .funct(funct),
        .opcode(opcode)
    );

    RegisterFile regfile(
        .clk(clk),
        .rst(rst),
        .WR(RegWrite),
        .RD(1'b1),
        .Sel_i1(write_reg),
        .Sel_o1(rs[3:0]),
        .Sel_o2(rt[3:0]),
        .Ip1((MemRead) ? mem_out : alu_res),
        .Op1(reg_out1),
        .Op2(reg_out2)
    );

    assign alu_srcB = (ALUSrc) ? sign_ext_imm : reg_out2;

    ALU alu(
        .i(ALUSrc),
        .SrcA(reg_out1),
        .SrcB(alu_srcB),
        .af(alu_ctrl),
        .Alures(alu_res),
        .Zero(zero_flag),
        .Neg(neg_flag),
        .ovfalu(ovfalu_flag)
    );

    assign alu_result = alu_res;

    // Memory read
    assign mem_out = (MemRead) ? memory[alu_res[7:0]] : 32'b0;

    // Memory write
    always @(posedge clk) begin
        if (MemWrite)
            memory[alu_res[7:0]] <= reg_out2;
    end

    // Simple PC update logic for branching 
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 0;
        else if (Branch && zero_flag)
            PC <= PC + 4 + (sign_ext_imm << 2); 
        else
            PC <= PC + 4;
    end

endmodule
