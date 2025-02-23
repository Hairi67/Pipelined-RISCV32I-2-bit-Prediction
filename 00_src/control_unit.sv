module control_unit (
	// Input
	input logic [31:0] i_instr,
	
	// Output
	output logic br_sel_o,					
	output logic rd_wren_o,
	output logic br_unsigned_o,
	output logic op_a_sel_o,
	output logic op_b_sel_o,
	output logic [3:0] alu_op_o,
	output logic mem_wren_o,
	output logic [2:0] fun_o,
	output logic [1:0] wb_sel_o,
	output logic insn_vld //invalid instructions
);
logic [14:0] out;

always_comb begin
    // Default invalid instruction
    insn_vld = 1'b0;

    // NOP 
    if (i_instr == 32'b0) begin
        insn_vld = 1'b1;
    end
    // Validate opcode 
    else if (i_instr[6:2] == 5'b01100 ||  // R-type
             i_instr[6:2] == 5'b00100 ||  // I-type
             i_instr[6:2] == 5'b00000 ||  // Load
             i_instr[6:2] == 5'b01000 ||  // Store
             i_instr[6:2] == 5'b11000 ||  // Branch
             i_instr[6:2] == 5'b01101 ||  // LUI
             i_instr[6:2] == 5'b00101 ||  // AUIPC
             i_instr[6:2] == 5'b11001 ||  // JALR
             i_instr[6:2] == 5'b11011) begin // JAL
        
        case (i_instr[6:2])
            5'b01100: begin // R-type check funct7
                if (i_instr[31:25] == 7'b0100000 || i_instr[31:25] == 7'b0000000) begin
                    insn_vld = 1'b1;
                end
            end
            5'b00100: begin // I-type
                if ((i_instr[14:12] == 3'b001 && i_instr[31:25] == 7'b0000000) || 
                    (i_instr[14:12] == 3'b101 && i_instr[31:25] == 7'b0000000) || 
                    (i_instr[14:12] == 3'b101 && i_instr[31:25] == 7'b0100000) ) begin
                    insn_vld = 1'b1;
                end
            end
            5'b00000: begin // Load
                if (i_instr[14:12] == 3'b000 || i_instr[14:12] == 3'b001 || i_instr[14:12] == 3'b010 || i_instr[14:12] == 3'b100 || i_instr[14:12] == 3'b101) begin
                    insn_vld = 1'b1;
                end
            end
            5'b01000: begin // Store
                if (i_instr[14:12] == 3'b000 || i_instr[14:12] == 3'b001 || i_instr[14:12] == 3'b010) begin
                    insn_vld = 1'b1;
                end
            end
            5'b11000: begin // Branch
                if (i_instr[14:12] == 3'b000 || 
		    i_instr[14:12] == 3'b001 || 
 		    i_instr[14:12] == 3'b100 || 
		    i_instr[14:12] == 3'b101 || 
		    i_instr[14:12] == 3'b110 || 
		    i_instr[14:12] == 3'b111) begin
                    if (i_instr[9:8] == 2'b0) begin
                        insn_vld = 1'b1;
                    end
                end
            end
            5'b01101: begin // LUI
                insn_vld = 1'b1;  
            end
            5'b00101: begin // AUIPC
                
                if (i_instr[13:12] == 2'b0 ) begin
                    insn_vld = 1'b1;
                end
            end
            5'b11011: begin // JAL
                // Check JAL immediate is aligned 
                if (i_instr[13:12] == 2'b0) begin
                    insn_vld = 1'b1;
                end
            end
            5'b11001: begin // JALR I type
                // Check JALR immediate is aligned 
                if (i_instr[14:12] == 3'b0 && i_instr[21:20] == 2'b0 ) begin
                    insn_vld = 1'b1;
                end
            end
            default: insn_vld = 1'b1;
        endcase
    end
end

always_comb begin
	if (i_instr == 0) begin
		out = 15'b0_0_0_0_0_0000_0_111_00;
	end
	else begin
		case (i_instr[6:2]) 
				5'b01100: begin 
						case ({i_instr[30],i_instr[14:12]})//R-type						
							4'b0000: out = 15'b0_1_0_0_0_0000_0_111_01;//ADD
							4'b1000: out = 15'b0_1_0_0_0_0001_0_111_01;//SUB
							4'b0001: out = 15'b0_1_0_0_0_0111_0_111_01;//SLL
							4'b0010: out = 15'b0_1_0_0_0_0010_0_111_01;//SLT
							4'b0011: out = 15'b0_1_0_0_0_0011_0_111_01;//SLTU
							4'b0100: out = 15'b0_1_0_0_0_0100_0_111_01;//XOR
							4'b0101: out = 15'b0_1_0_0_0_1000_0_111_01;//SRL
							4'b1010: out = 15'b0_1_0_0_0_1001_0_111_01;//SRA
							4'b0110: out = 15'b0_1_0_0_0_0101_0_111_01;//OR
							4'b0111: out = 15'b0_1_0_0_0_0110_0_111_01;//AND
							default: out = 15'b0_0_0_0_0_0000_0_111_00;
						endcase
						end
				5'b00100: begin 
						case ({i_instr[14:12]}) //I-type
							 3'b000: out = 15'b0_1_0_0_1_0000_0_111_01; //ADDI
							 3'b010: out = 15'b0_1_0_0_1_0010_0_111_01; //SLTI
							 3'b011: out = 15'b0_1_0_0_1_0011_0_111_01; //SLTIU
							 3'b100: out = 15'b0_1_0_0_1_0100_0_111_01; //XORI
							 3'b110: out = 15'b0_1_0_0_1_0101_0_111_01; //ORI
							 3'b111: out = 15'b0_1_0_0_1_0110_0_111_01; //ANDI
							 3'b001: out = 15'b0_1_0_0_1_0111_0_111_01; //SLLI
							 3'b101: 
									case (i_instr[30]) 
										1'b0: out = 15'b0_1_0_0_1_1000_0_111_01; //SRLI
										1'b1: out = 15'b0_1_0_0_1_1001_0_111_01; //SRAI
									endcase
							 default: out = 15'b0_0_0_0_0_0000_0_111_00;
							endcase
						end
				5'b00000: begin 
						case(i_instr[14:12])  		//I-type
							3'b000: out = 15'b0_1_0_0_1_0000_0_000_10;//LB
							3'b001: out = 15'b0_1_0_0_1_0000_0_001_10;//LH
							3'b010: out = 15'b0_1_0_0_1_0000_0_010_10;//LW
							3'b100: out = 15'b0_1_0_0_1_0000_0_100_10;//LBU
							3'b101: out = 15'b0_1_0_0_1_0000_0_101_10;//LHU
							default: out = 15'b0_0_0_0_0_0000_0_111_00;
						endcase
						end
				5'b01000: begin 
						case(i_instr[14:12])             //S-type
							3'b000: out = 15'b0_0_0_0_1_0000_1_000_00;//SB
							3'b001: out = 15'b0_0_0_0_1_0000_1_001_00;//SH
							3'b010: out = 15'b0_0_0_0_1_0000_1_010_00;//SW
							default: out = 15'b0_0_0_0_0_0000_0_111_00;
						endcase
						end
				5'b11000: begin 
						case(i_instr[14:12])           //B-type
								3'b000: out = 15'b1_0_0_1_1_0000_0_111_00;//BEQ
								3'b001: out = 15'b1_0_0_1_1_0000_0_111_00;//BNE
								3'b100: out = 15'b1_0_0_1_1_0000_0_111_00;//BLT
								3'b101: out = 15'b1_0_0_1_1_0000_0_111_00;//BGE
								3'b110: out = 15'b1_0_1_1_1_0000_0_111_00;//BLTU
								3'b111: out = 15'b1_0_1_1_1_0000_0_111_00;//BGEU
							default: out = 15'b0_0_0_0_0_0000_0_111_00;
							endcase
						end
					5'b01101: begin//U-type
							out = 15'b0_1_0_0_1_1111_0_111_01;//LUI
						end
					5'b00101: begin//U-type
							out = 15'b0_1_0_1_1_1110_0_111_01;//AUIPC
						end
					5'b11001: begin 
							if(i_instr[14:12] == 3'b000) 
								out = 15'b1_1_0_0_1_0000_0_111_00;//JALR
							else out = 15'b0_0_0_0_0_0000_0_111_00;
						end
					5'b11011: begin
							out = 15'b1_1_0_1_1_0000_0_111_00;//JAL
						end
			
			default: out = 15'b0_0_0_0_0_0000_0_111_00;
			endcase
		end	
	end			
	assign {br_sel_o, rd_wren_o, br_unsigned_o, op_a_sel_o, op_b_sel_o, alu_op_o, mem_wren_o, fun_o, wb_sel_o} = out ;
endmodule