module traffic_light_tb;

reg clk;
reg reset;

wire red;
wire yellow;
wire green;

// DUT instantiation
traffic_light dut(
    .clk(clk),
    .reset(reset),
    .red(red),
    .yellow(yellow),
    .green(green)
);

// Clock generation
always #5 clk = ~clk;

initial
begin
    clk = 0;
    reset = 1;

    #10 reset = 0;

    #100 $finish;
end

endmodule