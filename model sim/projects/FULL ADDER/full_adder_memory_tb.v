module full_adder_memory_tb;

reg [3:0] a,b;
reg cin,clk,rst,en;

wire [3:0] sum;
wire cout;

wire [3:0] d_mem,jk_mem,sr_mem,t_mem;

full_adder_memory uut(
    a,b,cin,clk,rst,en,
    sum,cout,d_mem,jk_mem,sr_mem,t_mem
);

// Clock
initial begin
    clk=0;
    forever #5 clk=~clk;
end

// Inputs
initial begin
    rst=1; en=0;
    a=0; b=0; cin=0;

    #10 rst=0;
    en=1;

    a=5; b=3; cin=0;
    #10;

    a=9; b=6; cin=0;
    #10;

    a=15; b=1; cin=0;
    #10;

    en=0;
    #10 $finish;
end

// Display
initial begin
    $monitor("A=%d B=%d Sum=%b Carry=%b D=%b JK=%b SR=%b T=%b",
    a,b,sum,cout,d_mem,jk_mem,sr_mem,t_mem);
end

endmodule