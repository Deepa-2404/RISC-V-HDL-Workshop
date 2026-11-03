module flip_tb;

logic clk;
logic reset;
logic D;
wire Q;

// DUT instantiation
flip dut (
    .clk(clk),
    .reset(reset),
    .D(D),
    .Q(Q)
);

// Clock generation
always #5 clk = ~clk;

initial
begin
    clk = 0;
    reset = 1;
    D = 0;

    #10 reset = 0;

    #10 D = 1;
    #10 D = 0;
    #10 D = 1;
    #10 D = 1;
    #10 D = 0;

    #20 $finish;
end

endmodule