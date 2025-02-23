module hazard (
	// Inputs
	input logic [4:0] IF_ID_rs1, IF_ID_rs2,				// Keep
	input logic [4:0] ID_EX_rd, EX_MEM_rd, MEM_WB_rd,	// Keep
	input logic [1:0] wb_sel_ex, wb_sel_mem, wb_sel_wb,	// Check whether if it is load (2'b10)
	input logic EX_branch,

	/* Output
	1'b1 =>	clear
	2'b00 =>	clear
	2'b01 =>	stall
	2'b11 =>	flush
	
	1: PC
	2: IF_ID
	2: ID_EX
	2: EX_MEM
	1: MEM_WB
	=> 8 bit */
	output logic [7:0] hazard_o		// {PC / IF_ID / ID_EX / EX_MEM / MEM_WB}
);


assign hazard_o = (EX_branch) ? 8'b0_11_11_00_0 :							// Jump - branch check first
						(((wb_sel_ex == 2'b10) && (ID_EX_rd != 0)) && ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2))) ? 8'b1_01_11_00_0 :
						(((wb_sel_mem == 2'b10) && (EX_MEM_rd != 0)) && ((EX_MEM_rd == IF_ID_rs1) || (EX_MEM_rd == IF_ID_rs2))) ? 8'b1_01_01_11_0 :
						(((wb_sel_wb == 2'b10) && (MEM_WB_rd != 0)) && ((MEM_WB_rd == IF_ID_rs1) || (MEM_WB_rd == IF_ID_rs2))) ? 8'b1_01_01_01_1 :
						8'b0;
						
endmodule: hazard