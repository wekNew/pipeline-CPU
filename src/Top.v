`include "./src/Adder.v"
`include "./src/ALU.v"
`include "./src/Controller.v"
`include "./src/Decoder.v"
`include "./src/Imme_Ext.v"
`include "./src/JB_Unit.v"
`include "./src/LD_Filter.v"
`include "./src/Mux2.v"
`include "./src/Mux3.v"
`include "./src/Reg_PC.v"
`include "./src/RegFile.v"
`include "./src/SRAM.v"
`include "./src/Reg_D.v"
`include "./src/Reg_E.v"
`include "./src/Reg_M.v"
`include "./src/Reg_W.v"

module Top (
    input clk,
    input rst //
);
   
    Controller controller(
        .clk(clk),
        .rst(rst),
        .opcode(decoder.dc_out_opcode),
        .func3(decoder.dc_out_func3),
        .rd(decoder.dc_out_rd_index),
        .rs1(decoder.dc_out_rs1_index),
        .rs2(decoder.dc_out_rs2_index),
        .func7(decoder.dc_out_func7),
        .branch_alu_out(alu.alu_out[0]),

        .stall(),
        .next_pc_sel(),
        .F_im_w_en(),
        .D_rs1_data_sel(),
        .D_rs2_data_sel(),
        .E_rs1_data_sel(),
        .E_rs2_data_sel(),
        .E_jb_op1_sel(),
        .E_alu_op2_sel(),
        .E_alu_op1_sel(),
        .E_op(),
        .E_f3(),
        .E_f7(),
        .M_dm_w_en(),
        .W_wb_en(),
        .W_rd_index(),
        .W_f3(),
        .W_wb_data_sel()
    );

    Adder adder (
        .Current_pc(reg_PC.current_pc),

        .After_pc()
    );

    Reg_PC reg_PC (
        .clk(clk),
        .rst(rst),
        .next_pc(NEXT_PC.chosen_data),
        .stall(controller.stall),

        .current_pc()
    );

    SRAM im(
        .clk(clk),
        .w_en(controller.F_im_w_en),
        .address(reg_PC.current_pc[15:0]),
        .write_data(32'd0),

        .read_data()
    );

    SRAM dm(
        .clk(clk),
        .w_en(controller.M_dm_w_en),
        .address(reg_M.alu_out_out[15:0]),
        .write_data(reg_M.rs2_data_out),

        .read_data()
    );

    Reg_D reg_D(
        .clk(clk),
        .rst(rst),
        .stall(controller.stall),
        .jb(controller.next_pc_sel),
        .pc_in(reg_PC.current_pc),
        .inst_in(im.read_data),

        .pc_out(),
        .inst_out()
    );

    Reg_E reg_E(
        .clk(clk),
        .rst(rst),
        .stall(controller.stall),
        .jb(controller.next_pc_sel),
        .pc_in(reg_D.pc_out),
        .rs1_data_in(rs1_sel.chosen_data),
        .rs2_data_in(rs2_sel.chosen_data),
        .sext_imm_in(imme_ext.imm_ext_out),

        .pc_out(),
        .rs1_data_out(),
        .rs2_data_out(),
        .sext_imm_out()
    );
    
    Reg_M reg_M(
        .clk(clk),
        .rst(rst),
        .alu_out_in(alu.alu_out),
        .rs2_data_in(n_rs2_sel.chosen_data),

        .alu_out_out(),
        .rs2_data_out()
    );

    Reg_W reg_W (
        .clk(clk),
        .rst(rst),
        .alu_out_in(reg_M.alu_out_out),
        .ld_data_in(dm.read_data),

        .alu_out_out(),
        .ld_data_out()
    );

    Imme_Ext imme_ext (
        .inst(reg_D.inst_out),

        .imm_ext_out()
    );

    RegFile regfile (
        .clk(clk),
        .wb_en(controller.W_wb_en),
        .wb_data(wb_data.chosen_data),
        .rd_index(controller.W_rd_index),
        .rs1_index(decoder.dc_out_rs1_index),
        .rs2_index(decoder.dc_out_rs2_index),

        .rs1_data_out(),
        .rs2_data_out()
    );

    Decoder decoder(
        .inst(reg_D.inst_out),

        .dc_out_opcode(),
        .dc_out_func3(),
        .dc_out_func7(),
        .dc_out_rs1_index(),
        .dc_out_rs2_index(),
        .dc_out_rd_index()
    );
    
    ALU alu (
        .opcode(controller.E_op),
        .func3(controller.E_f3),
        .func7(controller.E_f7),
        .operand1(alu_op1_mux.chosen_data),
        .operand2(alu_op2_mux.chosen_data),

        .alu_out()
    );

    JB_Unit jb_unit (
        .opcode(controller.E_op),
        .operand1(jb_op1_mux.chosen_data),
        .operand2(reg_E.sext_imm_out),

        .jb_out()
    );

    LD_Filter ld_filter (
        .func3(controller.W_f3),
        .ld_data(reg_W.ld_data_out),

        .ld_data_f()
    );

    MUX_3 n_rs1_sel(
        .op0(wb_data.chosen_data), 
        .op1(reg_M.alu_out_out), 
        .op2(reg_E.rs1_data_out),
        .choose_signal(controller.E_rs1_data_sel),

        .chosen_data()
    );

    MUX_3 n_rs2_sel(
        .op0(wb_data.chosen_data), 
        .op1(reg_M.alu_out_out), 
        .op2(reg_E.rs2_data_out),
        .choose_signal(controller.E_rs2_data_sel),

        .chosen_data()
    );
    
    MUX_2 NEXT_PC (
        .op0(jb_unit.jb_out),
        .op1(adder.After_pc),
        .choose_signal(controller.next_pc_sel),

        .chosen_data()
    );

    MUX_2 rs1_sel(
        .op0(regfile.rs1_data_out), 
        .op1(wb_data.chosen_data),
        .choose_signal(controller.D_rs1_data_sel),

        .chosen_data()
    );

    MUX_2 rs2_sel(
        .op0(regfile.rs2_data_out), 
        .op1(wb_data.chosen_data),
        .choose_signal(controller.D_rs2_data_sel),

        .chosen_data()
    );

    MUX_2 jb_op1_mux (
        .op0(n_rs1_sel.chosen_data),
        .op1(reg_E.pc_out),
        .choose_signal(controller.E_jb_op1_sel),

        .chosen_data()
    );

    MUX_2 alu_op1_mux (
        .op0(n_rs1_sel.chosen_data),
        .op1(reg_E.pc_out),
        .choose_signal(controller.E_alu_op1_sel),

        .chosen_data()
    );

    MUX_2 alu_op2_mux (
        .op0(n_rs2_sel.chosen_data),
        .op1(reg_E.sext_imm_out),
        .choose_signal(controller.E_alu_op2_sel),

        .chosen_data()
    );

    MUX_2 wb_data (
        .op0(reg_W.alu_out_out),
        .op1(ld_filter.ld_data_f),
        .choose_signal(controller.W_wb_data_sel),

        .chosen_data()
    );

endmodule