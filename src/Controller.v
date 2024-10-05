`define R_type 5'b01100
`define I_type 5'b00100
`define I_type_load 5'b00000
`define S_type 5'b01000
`define B_type 5'b11000
`define U_type_lui 5'b01101
`define U_type_auipc 5'b00101
`define J_type_jal 5'b11011
`define I_type_jalr 5'b11001

module Controller (
    input clk,
    input rst,
    input [4:0] opcode,
    input [2:0] func3,
    input [4:0] rd,
    input [4:0] rs1,
    input [4:0] rs2,
    input func7,
    input branch_alu_out,

    output reg stall,
    output reg next_pc_sel,
    output [3:0] F_im_w_en,
    output reg D_rs1_data_sel,
    output reg D_rs2_data_sel,
    output reg [1:0] E_rs1_data_sel,
    output reg [1:0] E_rs2_data_sel,
    output reg E_jb_op1_sel,
    output reg E_alu_op2_sel,
    output reg E_alu_op1_sel,
    output reg [4:0] E_op,
    output reg [2:0] E_f3,
    output reg E_f7,
    output reg [3:0] M_dm_w_en,
    output reg W_wb_en,
    output reg [4:0] W_rd_index,
    output reg [2:0] W_f3,
    output reg W_wb_data_sel
);

    reg [4:0] E_rd;
    reg [4:0] E_rs1;
    reg [4:0] E_rs2;
    reg [4:0] M_op;
    reg [4:0] M_f3;
    reg [4:0] M_rd;
    reg [4:0] W_op;
    reg [4:0] W_rd;

    
    assign F_im_w_en = 4'd0;
//-----------------------------------------------------------------------------

    reg is_E_use_rs1, is_E_use_rs2, is_M_use_rd;
    reg is_D_use_rs1, is_D_use_rs2, is_W_use_rd;

    always @(*) begin
        case(E_op)
            `R_type:    begin
                is_E_use_rs1 <= 1'b1;
                is_E_use_rs2 <= 1'b1;
            end
            `I_type:    begin
                is_E_use_rs1 <= 1'b1;
                is_E_use_rs2 <= 1'b0;
            end
            `I_type_load:   begin
                is_E_use_rs1 <= 1'b1;
                is_E_use_rs2 <= 1'b0;
            end
            `S_type:    begin
                is_E_use_rs1 <= 1'b1;
                is_E_use_rs2 <= 1'b1;
            end
            `B_type:    begin
                is_E_use_rs1 <= 1'b1;
                is_E_use_rs2 <= 1'b1;
            end
            `U_type_lui:    begin
                is_E_use_rs1 <= 1'b0;
                is_E_use_rs2 <= 1'b0;
            end
            `U_type_auipc:  begin
                is_E_use_rs1 <= 1'b0;
                is_E_use_rs2 <= 1'b0;
            end
            `J_type_jal:    begin
                is_E_use_rs1 <= 1'b0;
                is_E_use_rs2 <= 1'b0;
            end
            `I_type_jalr:   begin
                is_E_use_rs1 <= 1'b1;
                is_E_use_rs2 <= 1'b0;
            end
            default:    begin
            end
        endcase
    end

    always @(*) begin
        case (M_op)
            `B_type:    begin
                is_M_use_rd <= 1'b0;
            end 
            `S_type:    begin
                is_M_use_rd <= 1'b0;
            end
            default:    begin
                is_M_use_rd <= 1'b1;
            end
        endcase
    end

    always @(*) begin
        if (is_E_use_rs1 && is_M_use_rd && (E_rs1 == M_rd) && M_rd != 0) begin
            E_rs1_data_sel <= 2'd1;
        end
        else if(is_E_use_rs1 && is_W_use_rd && (E_rs1 == W_rd) && W_rd != 0 ) begin
            E_rs1_data_sel <= 2'd0;
        end
        else begin
            E_rs1_data_sel <= 2'd2;
        end
    end

    always @(*) begin
        if (is_E_use_rs2 && is_M_use_rd && (E_rs2 == M_rd) && M_rd != 0) begin
            E_rs2_data_sel <= 2'd1;
        end
        else if(is_E_use_rs2 && is_W_use_rd && (E_rs2 == W_rd) && W_rd != 0 ) begin
            E_rs2_data_sel <= 2'd0;
        end
        else begin
            E_rs2_data_sel <= 2'd2;
        end
    end  

    always @(*) begin
        case(opcode)
            `R_type:    begin
                is_D_use_rs1 <= 1'b1;
                is_D_use_rs2 <= 1'b1;
            end
            `I_type:    begin
                is_D_use_rs1 <= 1'b1;
                is_D_use_rs2 <= 1'b0;
            end
            `I_type_load:   begin
                is_D_use_rs1 <= 1'b1;
                is_D_use_rs2 <= 1'b0;
            end
            `S_type:    begin
                is_D_use_rs1 <= 1'b1;
                is_D_use_rs2 <= 1'b1;
            end
            `B_type:    begin
                is_D_use_rs1 <= 1'b1;
                is_D_use_rs2 <= 1'b1;
            end
            `U_type_lui:    begin
                is_D_use_rs1 <= 1'b0;
                is_D_use_rs2 <= 1'b0;
            end
            `U_type_auipc:  begin
                is_D_use_rs1 <= 1'b0;
                is_D_use_rs2 <= 1'b0;
            end
            `J_type_jal:    begin
                is_D_use_rs1 <= 1'b0;
                is_D_use_rs2 <= 1'b0;
            end
            `I_type_jalr:   begin
                is_D_use_rs1 <= 1'b1;
                is_D_use_rs2 <= 1'b0;
            end
            default:    begin
            end
        endcase
    end

    always @(*) begin
        case (W_op)
            `B_type:    begin
                is_W_use_rd <= 1'b0;
            end 
            `S_type:    begin
                is_W_use_rd <= 1'b0;
            end
            default:    begin
                is_W_use_rd <= 1'b1;
            end
        endcase
    end

    always @(*) begin
        D_rs1_data_sel <= (is_D_use_rs1 && is_W_use_rd && rs1 == W_rd && W_rd != 0) ? 1'b1 : 1'b0;
        D_rs2_data_sel <= (is_D_use_rs2 && is_W_use_rd && rs2 == W_rd && W_rd != 0) ? 1'b1 : 1'b0;
    end

//-----------------------------------------------------------------------------
    reg is_D_rs1_E_rd_overlap, is_D_rs2_E_rd_overlap;

    always @(*) begin
        is_D_rs1_E_rd_overlap <= (is_D_use_rs1 && (rs1 == E_rd) && E_rd != 0) ? 1'd1 : 1'd0;
        is_D_rs2_E_rd_overlap <= (is_D_use_rs2 && (rs2 == E_rd) && E_rd != 0) ? 1'd1 : 1'd0;
        stall <= ((is_D_rs1_E_rd_overlap || is_D_rs2_E_rd_overlap) && (E_op == `I_type_load)) ? 1'd1 : 1'd0; 
    end 

    //stage_D to stage_E
    always @(posedge clk or posedge rst) begin
        if (rst == 1)   begin
            E_op <= 5'd0;
            E_f3 <= 3'd0;
            E_f7 <= 1'd0;
            E_rd <= 5'd0;
            E_rs1 <= 5'd0;
            E_rs2 <= 5'd0;  
        end
        else if(stall == 1) begin
            E_op <= 5'b00100;
            E_f3 <= 3'd0;
            E_f7 <= 1'd0;
            E_rd <= 5'd0;
            E_rs1 <= 5'd0;
            E_rs2 <= 5'd0;
        end
        else if(next_pc_sel == 0)   begin
            E_op <= 5'b00100;
            E_f3 <= 3'd0;
            E_f7 <= 1'd0;
            E_rd <= 5'd0;
            E_rs1 <= 5'd0;
            E_rs2 <= 5'd0;
        end
        else    begin
            E_op <= opcode;
            E_f3 <= func3;
            E_f7 <= func7;
            E_rd <= rd;
            E_rs1 <= rs1;
            E_rs2 <= rs2;
        end
    end

    always @(*) begin
        case(E_op)
            `R_type:    begin
                next_pc_sel = 1;
                E_jb_op1_sel = 1;
                E_alu_op1_sel = 0;
                E_alu_op2_sel = 0;
            end
            `I_type:    begin
                next_pc_sel = 1;
                E_jb_op1_sel = 1;
                E_alu_op1_sel = 0;
                E_alu_op2_sel = 1;
            end
            `I_type_load:   begin
                next_pc_sel = 1;
                E_jb_op1_sel = 1;
                E_alu_op1_sel = 0;
                E_alu_op2_sel = 1;
            end
            `S_type:    begin
                next_pc_sel = 1;
                E_jb_op1_sel = 1;
                E_alu_op1_sel = 0;
                E_alu_op2_sel = 1;
            end
            `B_type:    begin
                next_pc_sel = branch_alu_out; 
                E_jb_op1_sel = 1;
                E_alu_op1_sel = 0;
                E_alu_op2_sel = 0;
            end
            `U_type_lui:    begin
                next_pc_sel = 1;
                E_jb_op1_sel = 1;
                E_alu_op1_sel = 1;
                E_alu_op2_sel = 1;
            end
            `U_type_auipc:  begin
                next_pc_sel = 1;
                E_jb_op1_sel = 1;
                E_alu_op1_sel = 1;
                E_alu_op2_sel = 1;
            end
            `J_type_jal:    begin
                next_pc_sel = 0;
                E_jb_op1_sel = 1;
                E_alu_op1_sel = 1; 
                E_alu_op2_sel = 1;
            end
            `I_type_jalr:   begin
                next_pc_sel = 0;
                E_jb_op1_sel = 0;
                E_alu_op1_sel = 1;
                E_alu_op2_sel = 1;
            end
            default:    begin 
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            M_op <= 5'd0;
            M_rd <= 5'd0;
            M_f3 <= 3'd0;
        end
        else    begin
            M_op <= E_op;
            M_rd <= E_rd;
            M_f3 <= E_f3;
        end
    end

    always @(*) begin
        if(M_f3 == 3'b000 && M_op == `S_type)
            M_dm_w_en <= 4'b0001;  
        else if(M_f3 == 3'b001 && M_op == `S_type)
            M_dm_w_en <= 4'b0011;  
        else if(M_f3 == 3'b010 && M_op == `S_type)
            M_dm_w_en <= 4'b1111;  
        else 
            M_dm_w_en <= 4'b0000;  
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            W_op <= 5'd0;
            W_rd <= 5'd0;
            W_f3 <= 3'd0;
             
        end
        else    begin
            W_op <= M_op;
            W_rd <= M_rd;
            W_f3 <= M_f3;
        end
    end

    always @(*) begin
       case(W_op)
            `R_type:    begin
                W_wb_en <= 1;
                W_wb_data_sel <= 0;
                W_rd_index <= W_rd;
            end
            `I_type:    begin
                W_wb_en = 1;
                W_wb_data_sel = 0;
                W_rd_index <= W_rd;
            end
            `I_type_load:   begin
                W_wb_en = 1;
                W_wb_data_sel = 1;
                W_rd_index <= W_rd;
            end
            `S_type:    begin
                W_wb_en = 0;
                W_wb_data_sel = 0;
                W_rd_index <= W_rd;
            end
            `B_type:    begin
                W_wb_en = 0;
                W_wb_data_sel = 0;
                W_rd_index <= W_rd;
            end
            `U_type_lui:    begin
                W_wb_en = 1;
                W_wb_data_sel = 0;
                W_rd_index <= W_rd;
            end
            `U_type_auipc:  begin
                W_wb_en = 1;
                W_wb_data_sel = 0;
                W_rd_index <= W_rd;
            end
            `J_type_jal:    begin
                W_wb_en = 1;
                W_wb_data_sel = 0;
                W_rd_index <= W_rd;
            end
            `I_type_jalr:   begin
                W_wb_en = 1;
                W_wb_data_sel = 0;
                W_rd_index <= W_rd;
            end
            default:    begin    
            end
        endcase
    end

endmodule