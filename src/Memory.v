module ThreePortRAM (
    input wire clk,            // Clock signal
    input wire we,             // Write enable
    input wire [4:0] addrA,    // Read address A
    input wire [4:0] addrB,    // Read address B
    input wire [4:0] addrW,    // Write address
    input wire [31:0] dataIn,  // Data to write
    output wire [31:0] dataOutA, // Data from read port A
    output wire [31:0] dataOutB  // Data from read port B
);

    // Memory array: 32 locations of 32-bit words
    reg [31:0] memory [31:0];

    // Write on rising edge of clock
    always @(posedge clk) begin
        if (we && addrW != 5'd0) begin
            memory[addrW] <= dataIn;
        end
    end

    // Asynchronous read, with addr 0 hardwired to 0
    assign dataOutA = (addrA == 5'd0) ? 32'b0 : memory[addrA];
    assign dataOutB = (addrB == 5'd0) ? 32'b0 : memory[addrB];

endmodule


module InstructionMemory (
    input wire [4:0] addr,           // Instruction address (PC[6:2])
    output wire [31:0] instruction   // 32-bit instruction output
);

    // Memory array: 32 locations of 32-bit instructions
    reg [31:0] memory [31:0];
    
    initial begin
        // Load instructions from file
        $readmemb("C:\\ExamProjects\\MIPS_Proccessor\\memInstructions.txt", memory);
        // Alternative: $readmemh("memInstructions.txt", memory) for hex format
    end
    
    // Asynchronous read - output instruction immediately when address changes
    assign instruction = memory[addr];
    
endmodule