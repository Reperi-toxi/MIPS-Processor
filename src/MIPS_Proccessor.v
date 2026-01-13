module MIPS_Processor (
    input wire clk,
    input wire rst,
    output wire [31:0] aluresout,
    output wire [31:0] shift_resultout,
    output wire [31:0] GP_DATA_INout
);

    // Program Counter
    reg [31:0] PC;
    reg [31:0] PC_next;
    wire [31:0] PC_plus_4, PC_branch;
    
    // Instruction Memory and Instruction Fields
    wire [31:0] instruction;
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd, shamt;
    wire [15:0] immediate;
    wire [25:0] jump_addr;
    
    // Control Signals
    wire RegWrite, ALUSrc, MemWrite, MemRead, Branch, Jump;
    wire [1:0] ALUOp;
    wire RegDst, MemtoReg, PCSrc;
    
    // Register File Signals
    wire [4:0] write_reg;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;
    
    // ALU Signals
    wire [31:0] alu_input1, alu_input2, alu_result;
    wire [31:0] immediate_extended;
    wire [3:0] alu_control;
    wire zero_flag, neg_flag, overflow_flag;
    
    // Memory Signals
    wire [31:0] mem_read_data;
    
    // Branch Control
    reg [3:0] branch_control;
    wire branch_result;
    
    // Shifter Signals
    wire [31:0] shift_result;
    reg [1:0] shift_funct;
    
    // Jump Signals
    wire [31:0] jump_address;
    
    // Immediate Extension Control
    wire immediate_unsigned;
    
    // PROGRAM COUNTER LOGIC
    
    // PC + 4 calculation
    assign PC_plus_4 = PC + 32'd4;
    
    // Branch address calculation (PC + 4 + (sign_extended_immediate << 2))
    assign PC_branch = PC_plus_4 + (immediate_extended << 2);
    
    // Jump address calculation
    assign jump_address = {PC_plus_4[31:28], jump_addr, 2'b00};
    
    // PC Source Multiplexer (PC_MUX)
    assign PCSrc = Branch & branch_result;
    
    always @(*) begin
        if (Jump)
            PC_next = jump_address;
        else if (PCSrc)
            PC_next = PC_branch;
        else
            PC_next = PC_plus_4;
    end
    
    // PC Register
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 32'b0;
        else
            PC <= PC_next;
    end
    
    // INSTRUCTION MEMORY 
    
    InstructionMemory instruction_memory (
        .addr(PC[6:2]),               // PC address (word-aligned)
        .instruction(instruction)
    );
    
    // INSTRUCTION DECODE
    
    // Extract instruction fields
    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign shamt = instruction[10:6];
    assign funct = instruction[5:0];
    assign immediate = instruction[15:0];
    assign jump_addr = instruction[25:0];
    
    // Control Unit
    instruction_decoder control_unit (
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
    
    // Additional control signals
    assign RegDst = (opcode == 6'b000000); // R-type instructions
    assign MemtoReg = (opcode == 6'b100011); // Load word
    assign Jump = (opcode == 6'b000010) || (opcode == 6'b000011); // j, jal
    assign immediate_unsigned = (opcode == 6'b001101) || (opcode == 6'b001111); // ori, lui
    
    // REGISTER FILE
    
    // Register destination multiplexer (part of GP_MUX)
    assign write_reg = RegDst ? rd : rt;
    
    RegisterFile register_file (
        .clk(clk),
        .rst(rst),
        .WR(RegWrite),
        .RD(1'b1),                   // Always enable reading
        .Sel_i1(write_reg),
        .Sel_o1(rs),
        .Sel_o2(rt),
        .Ip1(write_data),
        .Op1(read_data1),
        .Op2(read_data2)
    );
    
    // IMMEDIATE EXTENSION
    
    ImmediateExt #(.N(16), .M(32)) imm_ext (
        .clk(clk),
        .immediateIN(immediate),
        .U(immediate_unsigned),
        .immediateOUT(immediate_extended)
    );
    
    // ALU AND ALU CONTROL
    
    // ALU Control Unit
    ALU_Control alu_ctrl (
        .ALUOp(ALUOp),
        .funct(funct),
        .opcode(opcode),
        .ALU_Control(alu_control)
    );
    
    // ALU input multiplexer (ALU_OP_MUX)
    assign alu_input1 = read_data1;
    assign alu_input2 = ALUSrc ? immediate_extended : read_data2;
    
    // Main ALU
    ALU main_alu (
        .i(ALUSrc),                  // I-type instruction indicator
        .SrcA(alu_input1),
        .SrcB(alu_input2),
        .af(alu_control),
        .Alures(alu_result),
        .Zero(zero_flag),
        .Neg(neg_flag),
        .ovfalu(overflow_flag)
    );
    
    // BRANCH CONTROL UNIT
    
    // Branch control function encoding
    always @(*) begin
        case (opcode)
            6'b000100: branch_control = 4'b1000; // beq
            6'b000101: branch_control = 4'b1010; // bne
            6'b000001: begin // bgez, bltz (determined by rt field)
                case (rt)
                    5'b00000: branch_control = 4'b0010; // bltz
                    5'b00001: branch_control = 4'b0011; // bgez
                    default:  branch_control = 4'b0000;
                endcase
            end
            6'b000110: branch_control = 4'b1100; // blez
            6'b000111: branch_control = 4'b1110; // bgtz
            default:   branch_control = 4'b0000;
        endcase
    end
    
    BCE_Unit branch_unit (
        .a(read_data1),
        .b(read_data2),
        .bf(branch_control),
        .bcres(branch_result)
    );
    
    // SHIFTER
    
    // Shift function encoding
    always @(*) begin
    if ((opcode == 6'b000000) && 
        ((funct == 6'b000000) || (funct == 6'b000010) || (funct == 6'b000011))) begin
        // Only for actual shift instructions (R-type with shift funct codes)
        case (funct)
            6'b000000: shift_funct = 2'b00; // sll
            6'b000010: shift_funct = 2'b01; // srl
            6'b000011: shift_funct = 2'b11; // sra
            default:   shift_funct = 2'b10; // Force zero (shouldn't happen)
        endcase
    end else begin
        // For ALL non-shift instructions (add, addi, lw, sw, beq, etc.)
        shift_funct = 2'b10; // Use 2'b10 to get zero output from shifter
    end
end
    
    shifter shift_unit (
        .funct(shift_funct),
        .a(read_data2),            // rt register
        .N(shamt),                 // shift amount
        .R(shift_result)
    );
    
    // DATA MEMORY 
    
    ThreePortRAM data_memory (
        .clk(clk),
        .we(MemWrite),
        .addrA(alu_result[6:2]),      // Load address
        .addrB(5'b0),                 // Not used
        .addrW(alu_result[6:2]),      // Store address
        .dataIn(read_data2),          // Store data (rt register)
        .dataOutA(mem_read_data),
        .dataOutB()                   // Not used
    );
    
    // GP_MUX
    
    always @(*) begin
        if (opcode == 6'b001111) begin // lui instruction
            write_data = {immediate, 16'b0}; // Load upper immediate
        end else if (MemtoReg) begin
            write_data = mem_read_data;      // Load from memory
        end else if ((opcode == 6'b000000) && 
                    ((funct == 6'b000000) || (funct == 6'b000010) || (funct == 6'b000011))) begin
            write_data = shift_result;       // Shift operations
        end else begin
            write_data = alu_result;         // ALU result
        end
    end
	 
    // OUTPUT ASSIGNMENTS
    assign aluresout = alu_result;
    assign shift_resultout = shift_result;
    assign GP_DATA_INout = write_data;
    
endmodule