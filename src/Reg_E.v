module Reg_E (
    input clk,
    input rst,
    input stall,
    input jb,
    input [31:0] pc_in,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [31:0] sext_imm_in,
    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] sext_imm_out
);

    always @(posedge clk or posedge rst) begin
        if ((rst == 1)|(stall == 1)|(jb == 0))   begin
            pc_out <= 32'd0;
            rs1_data_out <= 32'd0;
            rs2_data_out <= 32'd0;
            sext_imm_out <= 32'd0;
        end
        else    begin
            pc_out <= pc_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            sext_imm_out <= sext_imm_in;
        end
    end

endmodule