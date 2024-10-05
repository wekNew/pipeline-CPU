module MUX_3 (
    input [31:0] op0, op1, op2,
    input [1:0] choose_signal,
    output reg [31:0] chosen_data
);

    always @(*) begin
        case(choose_signal)
            2'd0:   begin
                chosen_data <= op0;
            end
            2'd1:   begin
                chosen_data <= op1;
            end
            2'd2:   begin
                chosen_data <= op2;
            end
        endcase
    end

endmodule