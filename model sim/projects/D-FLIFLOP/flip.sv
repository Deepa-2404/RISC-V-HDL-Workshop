module flip(
    input logic clk,
    input logic reset,
    input logic D,
    output logic Q
);

always_ff @(posedge clk or posedge reset)
begin
    if (reset)
        Q <= 1'b0;
    else
        Q <= D;
end

endmodule