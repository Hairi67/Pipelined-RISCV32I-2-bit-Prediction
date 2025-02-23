module MEM_WB (
	// Input 
	input logic i_clk, i_rst_n,
		// Data
	input logic [31:0] instr_i,
	input logic [31:0] pc_four_i,
	input logic [31:0] alu_data_i,
	input logic [31:0] ld_data_i,
		// Hazard
	input logic sel_i,
		// Control Unit
			// WB
	input logic [4:0] rd_addr_i,
	input logic rd_wren_i,
	input logic [1:0] wb_sel_i,
	
	// Output
		// Data
	output logic [31:0] instr_o,
	output logic [31:0] pc_four_o,
	output logic [31:0] alu_data_o,
	output logic [31:0] ld_data_o,
		// Control Unit
			// WB
	output logic [4:0] rd_addr_o,
	output logic rd_wren_o,
	output logic [1:0] wb_sel_o
);

// WB
logic [7:0] WB_i, WB_o;
assign WB_i = {rd_addr_i, rd_wren_i, wb_sel_i};
assign {rd_addr_o, rd_wren_o, wb_sel_o} = WB_o;

always_ff @(posedge i_clk) begin
	if (!i_rst_n) begin							// Negative Reset
		instr_o <= 0;
		pc_four_o <= 0;
		alu_data_o <= 0;
		ld_data_o <= 0;
		
		WB_o <= 0;
	end
	else if (sel_i == 0) begin					// Normal - Not stall
		instr_o <= instr_i;
		pc_four_o <= pc_four_i;
		alu_data_o <= alu_data_i;
		ld_data_o <= ld_data_i;
		
		WB_o <= WB_i;
	end 
	else if (sel_i == 1) begin
		instr_o <= 0;
		pc_four_o <= 0;
		alu_data_o <= 0;
		ld_data_o <= 0;
		
		WB_o <= 0;
	end
end

endmodule: MEM_WB