module SRAM (
    input clk,
    input [3:0] w_en,
    input [15:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);
    reg [7:0] mem [0:65535];

    always @(posedge clk) begin
        
        case(w_en)
            4'b1111:    begin
                mem[address+1] <= write_data[15:8];
                mem[address+2] <= write_data[23:16];
                mem[address+3] <= write_data[31:24];
                mem[address] <= write_data[7:0];
            end
            4'b0011:    begin
                mem[address+1] <= write_data[15:8];
                mem[address] <= write_data[7:0];
            end
            4'b0001:    begin
                mem[address] <= write_data[7:0];
            end
            default:    begin
            end
        endcase
    end

    always @(*) begin
        read_data[7:0]   <= mem[address];
        read_data[15:8]  <= mem[address+1];
        read_data[23:16] <= mem[address+2];
        read_data[31:24] <= mem[address+3];
    end

endmodule