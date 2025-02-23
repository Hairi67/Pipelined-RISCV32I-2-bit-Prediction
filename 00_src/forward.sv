module forward (
	// Input
		// MEM
	input logic [4:0] mem_rd_addr_i,	// 0 -> Not forward
	input logic mem_rd_wren_i,			// 1 -> Forward
	input logic [4:0] wb_rd_addr_i,	// 0 -> Not forward
	input logic wb_rd_wren_i,			// 1 -> Forward
		// EX
	input logic [4:0] ex_rs1_addr_i,
	input logic [4:0] ex_rs2_addr_i,
	
	// Output
	// 0 -> Not forward
	// 1 -> Forward
	output logic [1:0] forwardA_o,
	output logic [1:0] forwardB_o
);

assign forwardA_o = (mem_rd_wren_i && (mem_rd_addr_i != 0) && (mem_rd_addr_i == ex_rs1_addr_i)) ? 2'b01 :
						  ((wb_rd_wren_i && (wb_rd_addr_i != 0) && (wb_rd_addr_i == ex_rs1_addr_i)) ? 2'b10 : 2'b00);

assign forwardB_o = (mem_rd_wren_i && (mem_rd_addr_i != 0) && (mem_rd_addr_i == ex_rs2_addr_i)) ? 2'b01 :
						  ((wb_rd_wren_i && (wb_rd_addr_i != 0) && (wb_rd_addr_i == ex_rs2_addr_i)) ? 2'b10 : 2'b00);
						  
endmodule 