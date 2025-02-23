module Pipeline_2bit_prediction
#( parameter WIDTH = 32,
   parameter HEX_DATA_WIDTH = 8,
	parameter DATA_WIDTH = 8)
(
   input logic                        i_clk,
   input logic                        i_rst_n, 
	input logic [WIDTH-1:0]            i_io_sw,
	input logic [DATA_WIDTH-1:0]       i_io_btn,

    // Outputs from the datapath

	output logic [DATA_WIDTH-1:0]      o_io_lcd,	
	output logic [DATA_WIDTH-1:0] 	   o_io_ledg,
   output logic [DATA_WIDTH-1:0]      o_io_ledr,
	 
	output logic [HEX_DATA_WIDTH-1:0]  o_io_hex0,
   output logic [HEX_DATA_WIDTH-1:0]  o_io_hex1,
   output logic [HEX_DATA_WIDTH-1:0]  o_io_hex2,
   output logic [HEX_DATA_WIDTH-1:0]  o_io_hex3,
   output logic [HEX_DATA_WIDTH-1:0]  o_io_hex4,
   output logic [HEX_DATA_WIDTH-1:0]  o_io_hex5,
   output logic [HEX_DATA_WIDTH-1:0]  o_io_hex6,
   output logic [HEX_DATA_WIDTH-1:0]  o_io_hex7,
   output logic                       o_insn_vld,
   output logic [WIDTH-1:0]           o_pc_debug,
	output logic [WIDTH-1:0] instruction,
   output logic [WIDTH-1:0] cycle_counter,	
	output logic [WIDTH-1:0] pc    
);

    // FETCH stage signals
   logic [WIDTH-1:0] pc_four;
   logic             pc_sel; //control signal
   logic [WIDTH-1:0] pc_nxt;
	//logic [WIDTH-1:0] instruction;
	//logic [WIDTH-1:0] pc; 
	 
	 //DECODE stage signals
	logic [WIDTH-1:0] imm_id;
	logic [WIDTH-1:0] rs1_data_id, rs2_data_id;
	logic [WIDTH-1:0] id_pc, id_instr;
	logic br_sel_id, rd_wren_id, br_unsigned_id, op_a_sel_id, op_b_sel_id, lsu_wren_id;
	logic [1:0] wb_sel_id;
	logic [2:0] func_id;
	logic [3:0] alu_op_id;
	logic [4:0] rd_addr_id, rs1_ifid, rs2_ifid;	
	 
	 //EXECUTE stage signals
	logic [WIDTH-1:0] alu_data_ex;
	logic [WIDTH-1:0] imm_ex;
	logic [WIDTH-1:0] operand_a_ex, operand_b_ex;
	logic [WIDTH-1:0] rs1_data_ex, rs2_data_ex;
	logic [WIDTH-1:0] instr_ex, pc_ex;
	logic [3:0] alu_op_ex;
	logic op_a_sel_ex, op_b_sel_ex, ex_br_sel, br_unsigned_ex, lsu_wren_ex, br_less_ex, br_equal_ex;
	logic rd_wren_ex;
	logic br_sel_ex;
	logic [2:0] func_ex;
	logic [4:0] rd_addr_ex;
	logic [1:0] wb_sel_ex;
	 
	 //MEM stage signals
/* 	 logic [1:0] wb_sel;
	 logic [WIDTH-1:0] wb_data;
	 logic [WIDTH-1:0]  ld_data;
	 logic lsu_wren; */
	logic [WIDTH-1:0] pc_mem;
	logic [WIDTH-1:0] ld_data_mem, pc_four_mem;
	logic [WIDTH-1:0] alu_data_mem, rs2_data_mem;
	logic [WIDTH-1:0] instr_mem;
	logic lsu_wren_mem;
	logic rd_wren_mem;
	logic [2:0] func_mem;
	logic [4:0] rd_addr_mem;
	logic [1:0] wb_sel_mem;
	logic [7:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;	 //hex led module

	//Write back Stage
	logic [WIDTH-1:0] pc_four_wb, alu_data_wb, ld_data_wb;
	logic [WIDTH-1:0] wb_data;
	logic [WIDTH-1:0] instr_wb;
	logic [1:0] wb_sel_wb;
	logic [4:0] rd_addr_wb;
	logic rd_wren_wb;	

	// Hazard
	logic [7:0] hz_o;
	logic hz_pc, hz_memwb;
	logic [1:0] hz_ifid, hz_idex, hz_exmem;
	assign hz_o = {hz_pc, hz_ifid, hz_idex, hz_exmem, hz_memwb};
	
	// Forward
	logic	[1:0] forwardA, forwardB;
	logic [WIDTH-1:0] forward_data, fwdA_data, fwdB_data;	
	
	//predict_table
	logic IF_jump_enable;
	logic [WIDTH-1:0] pc_predict;
	logic valid_predict;
	logic hit_miss_test;	
   logic insn_vld;

    // MUX for selecting the next PC (either PC+4 or a jump address)
	predict_table predict_table (
	  .clk_i        (i_clk),
	  .inst_F_i     (instruction),
	  .inst_X_i     (instr_ex),
	  .pc_F_i       (pc_four),
	  .pc_present_i (pc[14:2]), //.pc_present_i (pcF[13:2]),
	  .pc_X_i       (pc_ex[12:0]),//.pc_X_i       (pcE[13:0]),
	  .pc_result_i  (alu_data_ex),
	  .valid_bit_i  (br_sel_ex),
	  .nxt_pc_F_o   (pc_predict),
	  .pc_sel_o     (valid_predict),
	  .hit_miss_o   (hit_miss_test)	
	);	
	
    mux_2to1 mux_pc (
        .i_data1    (pc_predict),    
        .i_data2    (pc_ex + 32'd4),     
        .sel        (hit_miss_test),     
        .o_data_mux (pc_nxt)      
    );
    
    // Program Counter
    pc pc_ff (
        .i_nxt_pc   (pc_nxt),     
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
		  .sel_i	     (hz_pc),
        .o_pc       (pc)     
    );

    // Add 4 to the PC
    add add_block (
        .pc_i       (pc),    
        .pc_four_o  (pc_four)     
    );

    // Instruction Memory
    instr_mem instr_mem_block (
        .i_address  (pc),
        .o_instr    (instruction)
    );

	IF_ID IF_to_ID (
	.i_clk		(i_clk),
	.i_rst_n	(i_rst_n),
	.sel_i		(hz_ifid),
	.pc_if		(pc),
	.instr_if	(instruction),	
	.id_pc		(id_pc),
	.id_instr	(id_instr)
	);

    // Decode stage: Register File

	assign rs1_ifid = id_instr[19:15];
	assign rs2_ifid = id_instr[24:20];
	assign rd_addr_id = id_instr[11:7];
	
	control_unit ctrl_u (
		.i_instr		(id_instr),
		.br_sel_o		(br_sel_id),
		.rd_wren_o		(rd_wren_id),
		.br_unsigned_o	(br_unsigned_id),
		.op_a_sel_o		(op_a_sel_id),
		.op_b_sel_o		(op_b_sel_id),
		.alu_op_o		(alu_op_id),
		.mem_wren_o		(lsu_wren_id),
		.fun_o			(func_id),
		.wb_sel_o		(wb_sel_id),
		.insn_vld		(insn_vld)
	);	

    regfile reg_file_block (
        .clk_i      (i_clk),
        .rst_ni    (i_rst_n),
        .rd_wren  (rd_wren_wb),                 
        .rs1_addr (rs1_ifid),   
        .rs2_addr (rs2_ifid),   
        .rd_addr  (rd_addr_wb),   
        .rd_data  (wb_data),         // Data to write (coming from WB mux)
        .rs1_data (rs1_data_id),             
        .rs2_data (rs2_data_id)                
    );

    // Immediate Generator
    
    ImmGen ImmGen_block (
        .instr       (id_instr),
        .ImmOut      (imm_id)
    );

	ID_EX ID_to_EX (
		// Input
		.i_clk			(i_clk),
		.i_rst_n			(i_rst_n),
		.instr_i			(id_instr),
		.pc_i				(id_pc),
		.rs1_data_i		(rs1_data_id),
		.rs2_data_i		(rs2_data_id),
		.imm_i			(imm_id),
		.sel_i			(hz_idex),
		.alu_op_i		(alu_op_id),
		.op_a_i			(op_a_sel_id),
		.op_b_i			(op_b_sel_id),
		.br_sel_i		(br_sel_id),
		.br_unsigned_i	(br_unsigned_id),
		.mem_wren_i		(lsu_wren_id),
		.func_i			(func_id),
		.rd_addr_i		(rd_addr_id),
		.rd_wren_i		(rd_wren_id),
		.wb_sel_i		(wb_sel_id),
		
		// Output
		.instr_o			(instr_ex),
		.pc_o				(pc_ex),
		.rs1_data_o		(rs1_data_ex),
		.rs2_data_o		(rs2_data_ex),
		.imm_o			(imm_ex),
		.alu_op_o		(alu_op_ex),
		.op_a_o			(op_a_sel_ex),
		.op_b_o			(op_b_sel_ex),
		.br_sel_o		(ex_br_sel),
		.br_unsigned_o	(br_unsigned_ex),
		.mem_wren_o		(lsu_wren_ex),
		.func_o			(func_ex),
		.rd_addr_o		(rd_addr_ex),
		.rd_wren_o		(rd_wren_ex),
		.wb_sel_o		(wb_sel_ex)
	);
    
    // EXECUTE Stage
    

    brc brc_block (
        .i_rs1_data  (fwdA_data),
        .i_rs2_data  (fwdB_data),
        .i_br_un     (br_unsigned_ex),
        .o_br_less   (br_less_ex),
        .o_br_equal  (br_equal_ex)
    );

    // MUX for operand A
	
	mux_3to1 fwdA(
		.in1_i			(rs1_data_ex),
		.in2_i			(alu_data_mem),
		.in3_i			(wb_data),
		.sel_i			(forwardA),
		.out_o			(fwdA_data)
	);
	
    mux_2to1 op_A (
        .i_data1     (fwdA_data),    
        .i_data2     (pc_ex),
        .sel         (op_a_sel_ex),
        .o_data_mux  (operand_a_ex)
    );	

    // MUX for operand B
	
	mux_3to1 fwdB(
		.in1_i			(rs2_data_ex),
		.in2_i			(alu_data_mem),
		.in3_i			(wb_data),
		.sel_i			(forwardB),
		.out_o			(fwdB_data)
	);
	
    mux_2to1 op_B (
        .i_data1     (fwdB_data),    
        .i_data2     (imm_ex),
        .sel         (op_b_sel_ex),
        .o_data_mux  (operand_b_ex)
    );	

	//branch_control separate from control unit
	
	branch_control br_ctrl (
		.br_sel_i		(ex_br_sel),
		.br_less_i		(br_less_ex),
		.br_equal_i		(br_equal_ex),
		.instr_i			(instr_ex),
		.br_sel_o		(br_sel_ex)
	);	

    // ALU
   
    alu alu_block (
        .i_operand_a (operand_a_ex),
        .i_operand_b (operand_b_ex),
        .o_alu_data  (alu_data_ex),
        .i_alu_op    (alu_op_ex)
    );

	EX_MEM EX_to_MEM (
		// Input
		.i_clk			(i_clk),
		.i_rst_n		   (i_rst_n),
		.pc_i			   (pc_ex),
		.instr_i		   (instr_ex),
		.alu_data_i		(alu_data_ex),
		.rs2_data_i		(fwdB_data),
		.sel_i			(hz_exmem),
		.br_sel_i		(br_sel_ex),
		.mem_wren_i		(lsu_wren_ex),
		.func_i			(func_ex),
		.rd_addr_i		(rd_addr_ex),
		.rd_wren_i		(rd_wren_ex),
		.wb_sel_i		(wb_sel_ex),
		
		// Output
		.pc_o				(pc_mem),
		.instr_o			(instr_mem),
		.alu_data_o		(alu_data_mem),
		.rs2_data_o		(rs2_data_mem),
		.br_sel_o		(pc_sel),
		.mem_wren_o		(lsu_wren_mem),
		.func_o			(func_mem),
		.rd_addr_o		(rd_addr_mem),
		.rd_wren_o		(rd_wren_mem),
		.wb_sel_o		(wb_sel_mem)
	);

    // MEM Stage

	add add_block_2 (
		.pc_i					(pc_mem),
		.pc_four_o			(pc_four_mem)
	);

	// LSU unit
	lsu lsu_inst (
	  // Inputs
	  .i_clk          (i_clk),
	  .i_rst_n        (i_rst_n),
	  .i_lsu_addr     (alu_data_mem),
	  .i_func         (func_mem),
	  .i_lsu_wren     (lsu_wren_mem),
	  .i_st_data      (rs2_data_mem),
	  .i_io_sw        (i_io_sw),     // Switch data
	  .i_io_btn       (i_io_btn),    // Button data
	  
	  // Outputs
	  .o_ld_data      (ld_data_mem),
	  .o_io_lcd       (o_io_lcd),
	  .o_io_ledg      (o_io_ledg),
	  .o_io_ledr      (o_io_ledr),
	  .o_io_hex0      (hex0),
	  .o_io_hex1      (hex1),
	  .o_io_hex2      (hex2),
	  .o_io_hex3      (hex3),
	  .o_io_hex4      (hex4),
	  .o_io_hex5      (hex5),
	  .o_io_hex6      (hex6),
	  .o_io_hex7      (hex7)
	);
	
	//I/O	
	
	hexled hled0 (
		.i_data	(hex0),
		.o_hex	(o_io_hex0)
	);

	hexled hled1 (
		.i_data	(hex1),
		.o_hex	(o_io_hex1)
	);

	hexled hled2 (
		.i_data	(hex2),
		.o_hex	(o_io_hex2)
	);

	hexled hled3 (
		.i_data	(hex3),
		.o_hex	(o_io_hex3)
	);

	hexled hled4 (
		.i_data	(hex4),
		.o_hex	(o_io_hex4)
	);

	hexled hled5 (
		.i_data	(hex5),
		.o_hex	(o_io_hex5)
	);

	hexled hled6 (
		.i_data	(hex6),
		.o_hex	(o_io_hex6)
	);

	hexled hled7 (
		.i_data	(hex7),
		.o_hex	(o_io_hex7)
	); 

	MEM_WB MEM_to_WB (
		// Input
		.i_clk			(i_clk),
		.i_rst_n			(i_rst_n),
		.instr_i			(instr_mem),
		.pc_four_i		(pc_four_mem),
		.alu_data_i		(alu_data_mem),
		.ld_data_i		(ld_data_mem),
		.sel_i			(hz_memwb),
		.rd_addr_i		(rd_addr_mem),
		.rd_wren_i		(rd_wren_mem),
		.wb_sel_i		(wb_sel_mem),
		
		// Output
		.instr_o			(instr_wb),
		.pc_four_o		(pc_four_wb),
		.alu_data_o		(alu_data_wb),
		.ld_data_o		(ld_data_wb),
		.rd_addr_o		(rd_addr_wb),
		.rd_wren_o		(rd_wren_wb),
		.wb_sel_o		(wb_sel_wb)
	);

    // Write Back stage
    wbmux wbmux (
        .i_ld_data   (ld_data_wb),
        .i_alu_data  (alu_data_wb),
        .i_pc_four   (pc_four_wb),
        .i_wb_sel    (wb_sel_wb),
        .o_wb_data   (wb_data) // Connecting WB result to wb_data
    );

	// Hazard

	hazard hazd (
		.IF_ID_rs1		(rs1_ifid),
		.IF_ID_rs2		(rs2_ifid),
		.ID_EX_rd		(rd_addr_ex),
		.wb_sel_ex		(wb_sel_ex),
		.EX_MEM_rd		(rd_addr_mem),
		.wb_sel_mem		(wb_sel_mem),
		.MEM_WB_rd		(rd_addr_wb),
		.wb_sel_wb		(wb_sel_wb),
		.EX_branch		(valid_predict | hit_miss_test),
		.hazard_o		(hz_o)
	);

	// Forward

	forward fwd (
		.mem_rd_addr_i	(rd_addr_mem),
		.mem_rd_wren_i	(rd_wren_mem),
		.wb_rd_addr_i	(rd_addr_wb),
		.wb_rd_wren_i	(rd_wren_wb),
		.ex_rs1_addr_i	(instr_ex[19:15]),
		.ex_rs2_addr_i	(instr_ex[24:20]),
		.forwardA_o		(forwardA),
		.forwardB_o		(forwardB)
	);
	
    instruction_check checking (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_insn_vld    (insn_vld),
        .o_insn_vld    (o_insn_vld)

    );

    pc_debug debug_reg (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_pc          (pc),
        .o_pc_debug    (o_pc_debug)

    );
	 
	always @(posedge i_clk or negedge i_rst_n) begin
		 if (!i_rst_n)
			  cycle_counter <= 0;
		 else
			  cycle_counter <= cycle_counter + 1;
	end	 
endmodule
