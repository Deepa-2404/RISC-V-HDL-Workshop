
`timescale 1ns/1ps

module tb_riscv_5stage;

reg clk;
reg reset;

riscv_5stage dut(
    .clk(clk),
    .reset(reset)
);

// Clock generation
always #5 clk = ~clk;

integer i;

initial begin

    clk = 0;
    reset = 1;

    // Initialize memories
    for(i=0; i<64; i=i+1) begin
        dut.instruction_mem[i] = 32'h00000013;
        dut.data_mem[i] = 0;
    end

    // Instruction 1: ADDI x1, x0, 5
    dut.instruction_mem[0] = 32'h00500093;

    // Instruction 2: ADDI x2, x0, 7
    dut.instruction_mem[1] = 32'h00700113;

    // Instruction 3: ADD x3, x1, x2
    dut.instruction_mem[2] = 32'h002081B3;

    // Instruction 4: SUB x4, x3, x1
    dut.instruction_mem[3] = 32'h40118233;

    // Instruction 5: SW x3, 0(x0)
    dut.instruction_mem[4] = 32'h00302023;

    // Instruction 6: LW x5, 0(x0)
    dut.instruction_mem[5] = 32'h00002283;

    // Instruction 7: BEQ x4, x2, +8
    dut.instruction_mem[6] = 32'h00220463;

    // Instruction 8: ADDI x6, x0, 99 (flushed)
    dut.instruction_mem[7] = 32'h06300313;

    // Instruction 9: ADDI x7, x0, 11
    dut.instruction_mem[8] = 32'h00B00393;

    // Reset
    #20;
    reset = 0;

    // Wait for processor execution
    #300;

    // Display results
    $display("--------------------------------");
    $display("  RISC-V 32-BIT PROCESSOR");
    $display("--------------------------------");

    $display("x1 = %0d", dut.registers[1]);
    $display("x2 = %0d", dut.registers[2]);
    $display("x3 = %0d", dut.registers[3]);
    $display("x4 = %0d", dut.registers[4]);
    $display("x5 = %0d", dut.registers[5]);
    $display("x6 = %0d", dut.registers[6]);
    $display("x7 = %0d", dut.registers[7]);
    $display("Memory[0] = %0d", dut.data_mem[0]);

    // Verification
    if(dut.registers[1] == 5 &&
       dut.registers[2] == 7 &&
       dut.registers[3] == 12 &&
       dut.registers[4] == 7 &&
       dut.registers[5] == 12 &&
       dut.registers[6] == 0 &&
       dut.registers[7] == 11 &&
       dut.data_mem[0] == 12)

        $display("TEST PASSED");

    else
        $display("TEST FAILED");

    $display("--------------------------------");

    $finish;

end

// Monitor
initial begin
    $monitor("Time=%0t PC=%0d x3=%0d x5=%0d",
             $time, dut.pc,
             dut.registers[3],
             dut.registers[5]);
end

endmodule
