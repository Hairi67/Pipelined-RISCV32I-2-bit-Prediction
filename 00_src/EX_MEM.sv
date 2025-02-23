module EX_MEM (
	// Input
	input logic i_clk, i_rst_n,
		// Data
	input logic [31:0] pc_i,
	input logic [31:0] instr_i,
	input logic [31:0] alu_data_i,
	input logic [31:0] rs2_data_i,
		// Hazard
	input logic [1:0] sel_i,
		// Control Unit
			// MEM
	input logic br_sel_i,
	input logic mem_wren_i,
	input logic [2:0] func_i,
			// WB
	input logic [4:0] rd_addr_i,
	input logic rd_wren_i,
	input logic [1:0] wb_sel_i,
	
	// Output
		// Data
	output logic [31:0] pc_o,
	output logic [31:0] instr_o,
	output logic [31:0] alu_data_o,
	output logic [31:0] rs2_data_o,
		// Control Unit
			// MEM
	output logic br_sel_o,
	output logic mem_wren_o,
	output logic [2:0] func_o,
			// WB
	output logic [4:0] rd_addr_o,
	output logic rd_wren_o,
	output logic [1:0] wb_sel_o
);

// MEM
logic [4:0] M_i, M_o;
assign M_i = {br_sel_i, mem_wren_i, func_i};
assign {br_sel_o, mem_wren_o, func_o} = M_o;

// WB
logic [7:0] WB_i, WB_o;
assign WB_i = {rd_addr_i, rd_wren_i, wb_sel_i};
assign {rd_addr_o, rd_wren_o, wb_sel_o} = WB_o;

always_ff @(posedge i_clk) begin
	if (!i_rst_n) begin							// Negative reset
		pc_o <= 0;
		instr_o <= 0;
		alu_data_o <= 0;
		rs2_data_o <= 0;
		
		M_o <= 0;
		WB_o <= 0;
	end
	else if (sel_i == 2'b11) begin			// Hazard: Clear
		pc_o <= 0;
		instr_o <= 0;
		alu_data_o <= 0;
		rs2_data_o <= 0;
		
		M_o <= 0;
		WB_o <= 0;
	end if (sel_i == 2'b00) begin				// Normal - Not stall
		pc_o <= pc_i;
		instr_o <= instr_i;
		alu_data_o <= alu_data_i;
		rs2_data_o <= rs2_data_i;
		
		M_o <= M_i;
		WB_o <= WB_i;
	end												// Final case: Stall
end

endmodule: EX_MEM