`define R_type 5'b01100
`define I_type 5'b00100
`define I_type_load 5'b00000
`define S_type 5'b01000
`define B_type 5'b11000
`define U_type_lui 5'b01101
`define U_type_auipc 5'b00101
`define J_type_jal 5'b11011
`define I_type_jalr 5'b11001

module Imme_Ext (
    input [31:0] inst,
    output reg[31:0] imm_ext_out
);

    always @(*) begin
        casex(inst[6:2])
            5'b00x00:   begin//I_type
                imm_ext_out = {{20{inst[31]}}, inst[31: 20]};
            end
            5'b01000:   begin//S_type
                imm_ext_out = {{20{inst[31]}}, inst[31: 25], inst[11: 7]};
            end
            5'b11000:   begin//B_type
                imm_ext_out = {{20{inst[31]}}, inst[7], inst[30:25], inst[11: 8], 1'b0};
            end
            5'b0x101:   begin//U_type
                imm_ext_out = {inst[31:12], 12'd0};
            end
            5'b11011:   begin//J_type
                imm_ext_out = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end
            5'b11001:   begin//I_type_jalr
                imm_ext_out = {{20{inst[31]}}, inst[31: 20]};
            end
            default:    begin//whatever
                imm_ext_out = inst;
            end
        endcase
    end

endmodule