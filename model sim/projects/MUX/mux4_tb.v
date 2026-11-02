`timescale 1ns/1ps

module mux4_tb;

reg I0, I1, I2, I3;
reg S1, S0;

wire Y;

mux4 DUT(I0,I1,I2,I3,S1,S0,Y);

initial begin

$monitor("S1=%b S0=%b Y=%b",S1,S0,Y);

I0=0; I1=1; I2=0; I3=1;

S1=0; S0=0; #10;
S1=0; S0=1; #10;
S1=1; S0=0; #10;
S1=1; S0=1; #10;

$finish;

end

endmodule