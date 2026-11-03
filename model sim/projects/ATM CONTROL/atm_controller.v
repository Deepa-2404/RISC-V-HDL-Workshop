
module atm_controller(
    input clk,
    input reset,
    input card_inserted,
    input submit,
    input [15:0] pin,
    input [7:0] amount,
    output reg dispense,
    output reg done,
    output reg error,
    output reg [7:0] balance
);

reg [2:0] state;

parameter IDLE         = 3'b000,
          PIN_CHECK    = 3'b001,
          AMOUNT_CHECK = 3'b010,
          DISPENSE     = 3'b011,
          SUCCESS      = 3'b100,
          ERROR        = 3'b101;

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        state <= IDLE;
        balance <= 8'd100;
        dispense <= 0;
        done <= 0;
        error <= 0;
    end
    else
    begin
        dispense <= 0;
        done <= 0;
        error <= 0;

        case (state)

            IDLE:
            begin
                if (card_inserted)
                    state <= PIN_CHECK;
            end

            PIN_CHECK:
            begin
                if (submit)
                begin
                    if (pin == 16'd1234)
                        state <= AMOUNT_CHECK;
                    else
                        state <= ERROR;
                end
            end

            AMOUNT_CHECK:
            begin
                if (submit)
                begin
                    if ((amount > 0) && (amount <= balance))
                        state <= DISPENSE;
                    else
                        state <= ERROR;
                end
            end

            DISPENSE:
            begin
                dispense <= 1;
                balance <= balance - amount;
                state <= SUCCESS;
            end

            SUCCESS:
            begin
                done <= 1;
                state <= IDLE;
            end

            ERROR:
            begin
                error <= 1;
                state <= IDLE;
            end

            default:
                state <= IDLE;

        endcase
    end
end

endmodule
