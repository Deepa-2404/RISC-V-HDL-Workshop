module traffic_light(
    input clk,
    input reset,
    output reg red,
    output reg yellow,
    output reg green
);

reg [1:0] state;

parameter RED    = 2'b00,
          GREEN  = 2'b01,
          YELLOW = 2'b10;

// State transition
always @(posedge clk or posedge reset)
begin
    if (reset)
        state <= RED;
    else
    begin
        case(state)

            RED:
                state <= GREEN;

            GREEN:
                state <= YELLOW;

            YELLOW:
                state <= RED;

            default:
                state <= RED;

        endcase
    end
end

// Traffic light output
always @(*)
begin
    red = 0;
    yellow = 0;
    green = 0;

    case(state)

        RED: red = 1;

        GREEN: green = 1;

        YELLOW: yellow = 1;

        default: red = 1;

    endcase
end

endmodule