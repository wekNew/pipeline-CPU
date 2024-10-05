`define R_type 5'b01100
`define I_type 5'b00100
`define I_type_load 5'b00000
`define S_type 5'b01000
`define B_type 5'b11000
`define U_type_lui 5'b01101
`define U_type_auipc 5'b00101
`define J_type_jal 5'b11011
`define I_type_jalr 5'b11001

`define Add  3'b000
`define Sll  3'b001
`define Slt  3'b010
`define Sltu 3'b011
`define Xor  3'b100
`define Sr   3'b101
`define Or   3'b110
`define And  3'b111
module ALU (
    input [4:0] opcode,
    input [2:0] func3,
    input func7,
    input [31:0] operand1,
    input [31:0] operand2,
    output reg [31:0] alu_out
);

    wire [4:0] shift_bits;
    assign shift_bits = $signed(operand2[4:0]);

    always @(*) begin
        case(opcode)
            `R_type:     begin
                case(func3)
                    `Add:   begin
                        alu_out = (func7 == 0) ? (operand1 + operand2)  : (operand1 - operand2);
                    end
                    `Sll:   begin
                        alu_out = operand1 << operand2[4:0];
                    end
                    `Slt:   begin
                        alu_out = ($signed(operand1) < $signed(operand2)) ? 32'd1 : 32'd0;
                    end
                    `Sltu:  begin
                        alu_out = ((operand1) < (operand2)) ? 32'd1 : 32'd0;
                    end
                    `Xor:   begin
                        alu_out = operand1 ^ operand2;
                    end
                    `Sr:    begin
                        alu_out = (func7 == 0) ? (operand1 >> operand2[4:0]) : (operand1 >>> operand2[4:0]);
                    end
                    `Or:    begin
                        alu_out = operand1 | operand2;
                    end
                    `And:   begin
                        alu_out = operand1 & operand2;
                    end
                    default:    begin
                    end
                endcase
            end
            `I_type:     begin
                case(func3)
                    `Add:   begin
                        alu_out = (operand1 + operand2);
                    end
                    `Sll:   begin
                        alu_out = operand1 << operand2[4:0];
                    end
                    `Slt:   begin
                        alu_out = ($signed(operand1) < $signed(operand2)) ? 32'd1 : 32'd0;
                    end
                    `Sltu:  begin
                        alu_out = ($unsigned(operand1) < $unsigned(operand2)) ? 32'd1 : 32'd0;
                    end
                    `Xor:   begin
                        alu_out = operand1 ^ operand2;
                    end
                    `Sr:    begin
                        alu_out = (func7 == 0) ? ($signed(operand1) >> $signed(operand2[4:0])) : ($signed(operand1) >>> $signed(operand2[4:0]));
                    end
                    `Or:    begin
                        alu_out = operand1 | operand2;
                    end
                    `And:   begin
                        alu_out = operand1 & operand2;
                    end
                    default:    begin
                    end
                endcase
            end
            `I_type_load:     begin
                alu_out = operand1 + operand2;
            end
            `S_type:     begin
                alu_out = operand1 + operand2;
            end
            `B_type:     begin
                case(func3)
                    3'b000:     begin// beq
                        alu_out = ($signed (operand1) == $signed (operand2)) ? 32'b0 : 32'b1;
                    end
                    3'b001:     begin// bne
                        alu_out = ($signed (operand1) != $signed (operand2)) ? 32'b0 : 32'b1;
                    end
                    3'b100:     begin// blt
                        alu_out = ($signed (operand1) < $signed (operand2)) ? 32'b0 : 32'b1;
                    end
                    3'b101:     begin// bge
                        alu_out = ($signed (operand1) >= $signed (operand2)) ? 32'b0 : 32'b1;
                    end
                    3'b110:     begin// bltu
                        alu_out = ($unsigned (operand1) < $unsigned (operand2)) ? 32'b0 : 32'b1;
                    end
                    3'b111:     begin// bgeu
                        alu_out = ($unsigned (operand1) >= $unsigned (operand2)) ? 32'b0 : 32'b1;
                    end
                    default:    begin
                    end
                endcase
            end
            `U_type_lui:     begin
                alu_out = operand2;
            end
            `U_type_auipc:     begin
                alu_out = operand1 + operand2;
            end
            `J_type_jal:     begin
                alu_out = operand1 + 32'd4;
            end
            `I_type_jalr:     begin
                alu_out = operand1 + 32'd4;
            end
            default:    begin
            end
        endcase
    end
    
endmodule