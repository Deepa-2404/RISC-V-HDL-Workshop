`timescale 1ns/1ps

module half_adder(
    input A, B,
    output Sum, Carry
);

xor (Sum, A, B);
and (Carry, A, B);

endmodule


module full_adder(
    input A, B, Cin,
    output Sum, Cout
);

wire w1, w2, w3;

xor (w1, A, B);
xor (Sum, w1, Cin);

and (w2, A, B);
and (w3, w1, Cin);

or (Cout, w2, w3);

endmodule


module four_bit_adder(
    input [3:0] A, B,
    output [4:0] Sum
);

wire c1, c2, c3;

half_adder HA0(A[0], B[0], Sum[0], c1);

full_adder FA1(A[1], B[1], c1, Sum[1], c2);

full_adder FA2(A[2], B[2], c2, Sum[2], c3);

full_adder FA3(A[3], B[3], c3, Sum[3], Sum[4]);

endmodule