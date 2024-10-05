module MUX_2 (
    input [31:0] op0, op1,
    input choose_signal,
    output reg [31:0] chosen_data
);

    always @(*) begin
        chosen_data = (choose_signal == 0) ? op0 : op1;         
    end

endmodule