module top (
	input logic [17:0] SW,
	input logic CLOCK_50,
	output logic [6:0] HEX0,
	output logic [6:0] HEX1,
	output logic [6:0] HEX2,
	output logic [6:0] HEX3,
	output logic [6:0] HEX4,
	output logic [6:0] HEX5,
	output logic [6:0] HEX6,
	output logic [6:0] HEX7
);

Pipeline_2bit_prediction dut(
	.i_clk			(CLOCK_50),
	.i_rst_n			(SW[17]),
	.i_io_sw			(SW[15:0]),
	.o_io_hex0		(HEX0[6:0]),
	.o_io_hex1		(HEX1[6:0]),
	.o_io_hex2		(HEX2[6:0]),
	.o_io_hex3		(HEX3[6:0]),
	.o_io_hex4		(HEX4[6:0]),
	.o_io_hex5		(HEX5[6:0]),
	.o_io_hex6		(HEX6[6:0]),
	.o_io_hex7		(HEX7[6:0])
);

endmodule: top