`define lb  3'b000
`define lh  3'b001
`define lw  3'b010
`define lbu 3'b100
`define lhu 3'b101

module LD_Filter (
    input [2:0] func3,
    input [31:0] ld_data,
    output reg [31:0] ld_data_f
);

    always @(*) begin
        case (func3)
            `lb:    begin
                ld_data_f = {{24{ld_data[7]}}, ld_data[7:0]};
            end 
            `lh:    begin
                ld_data_f = {{16{ld_data[15]}}, ld_data[15:0]};
            end 
            `lw:    begin
                ld_data_f = ld_data;
            end 
            `lbu:   begin
                ld_data_f = {24'b0, ld_data[7:0]};
            end
            `lhu:   begin
                ld_data_f = {16'b0, ld_data[15:0]};
            end
            default:    begin
            end
        endcase
    end
    
endmodule