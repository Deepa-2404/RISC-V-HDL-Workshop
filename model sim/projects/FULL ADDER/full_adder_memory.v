module full_adder_memory(
    input [3:0] a,b,
    input cin,clk,rst,en,
    output [3:0] sum,
    output cout,
    output reg [3:0] d_mem,
    output reg [3:0] jk_mem,
    output reg [3:0] sr_mem,
    output reg [3:0] t_mem
);

// Full Adder
assign {cout,sum} =
    {1'b0,a}+{1'b0,b}+cin;

// D Flip-Flop
always @(posedge clk or posedge rst)
if(rst) d_mem <= 0;
else if(en) d_mem <= sum;

// JK Flip-Flop
always @(posedge clk or posedge rst)
if(rst) jk_mem <= 0;
else if(en) jk_mem <= sum;

// SR Flip-Flop
always @(posedge clk or posedge rst)
if(rst) sr_mem <= 0;
else if(en) sr_mem <= sum;

// T Flip-Flop
always @(posedge clk or posedge rst)
if(rst) t_mem <= 0;
else if(en) t_mem <= sum;

endmodule