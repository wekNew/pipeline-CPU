module JB_Unit (
    input [4:0] opcode,
    input [31:0] operand1,
    input [31:0] operand2,
    output reg [31:0] jb_out
);

    always @(*) begin
        case(opcode)
            5'b11000:   begin
                jb_out = operand1 + operand2;
            end
            5'b11011:   begin
                jb_out = operand1 + operand2;
            end
            5'b11001:   begin
                jb_out = (operand1 + operand2) & (~32'd1) ;
            end
            default:    begin
            end
        endcase     
    end

endmodule