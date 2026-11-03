
module tb_atm_controller;

reg clk, reset, card_inserted, submit;
reg [15:0] pin;
reg [7:0] amount;

wire dispense, done, error;
wire [7:0] balance;

atm_controller uut(
    .clk(clk),
    .reset(reset),
    .card_inserted(card_inserted),
    .submit(submit),
    .pin(pin),
    .amount(amount),
    .dispense(dispense),
    .done(done),
    .error(error),
    .balance(balance)
);

always #5 clk = ~clk;

initial
begin
    clk = 0;
    reset = 1;
    card_inserted = 0;
    submit = 0;
    pin = 0;
    amount = 0;

    #10 reset = 0;

    // Insert ATM card
    #10 card_inserted = 1;
    #10 card_inserted = 0;

    // Enter correct PIN
    pin = 16'd1234;
    submit = 1;
    #10 submit = 0;

    // Enter withdrawal amount
    #10 amount = 30;
    submit = 1;
    #10 submit = 0;

    // Wait for transaction
    #30;

    $display("ATM TRANSACTION RESULT");
    $display("Cash Dispensed = %b", dispense);
    $display("Final Balance = %d", balance);
    $display("Transaction Done = %b", done);
    $display("Error = %b", error);

    $finish;
end

endmodule
