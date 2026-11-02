module dff_tb;

reg clk,d;
wire q;

dff uut(clk,d,q);

initial begin
clk=0;
forever #5 clk=~clk;
end

initial begin
d=0;
#10 d=1;
#10 d=0;
#10 d=1;
#10 $finish;
end

initial
$monitor("clk=%b d=%b q=%b",clk,d,q);

endmodule