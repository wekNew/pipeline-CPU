module Reg_D (
    input clk,
    input rst,
    input stall,
    input jb,
    input [31:0] pc_in,
    input [31:0] inst_in,
    output reg [31:0] pc_out,
    output reg [31:0] inst_out
);

    always @(posedge clk or posedge rst) begin
            if (rst == 1) begin
                pc_out <= 32'd0;
                inst_out <= 32'd0;
            end
            else if (stall == 1)begin
                pc_out <= pc_out;       
                inst_out <= inst_out;
            end
            else if (jb == 0)begin
                pc_out <= pc_in;
                inst_out <= {{25'b0},{7'b0010011}};
            end
            else begin
                pc_out <= pc_in;
                inst_out <= inst_in;
            end
        end

endmodule