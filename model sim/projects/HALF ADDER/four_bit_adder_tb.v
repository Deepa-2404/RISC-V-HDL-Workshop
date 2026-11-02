`timescale 1ns/1ps

module four_bit_adder_tb;

reg [3:0] A, B;
wire [4:0] Sum;

four_bit_adder DUT(A, B, Sum);

initial begin

$monitor("A=%b B=%b Sum=%b", A, B, Sum);

A=4'b0000; B=4'b0000; #10;
A=4'b0101; B=4'b0011; #10;
A=4'b1010; B=4'b0101; #10;
A=4'b1111; B=4'b0001; #10;
A=4'b1111; B=4'b1111; #10;

$finish;

end
endmodule