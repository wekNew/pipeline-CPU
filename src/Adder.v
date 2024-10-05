module Adder(
    input [31:0] Current_pc,
    output [31:0] After_pc
);

    assign After_pc = Current_pc + 32'd4;

endmodule