module lsu
  #(parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
	 parameter HEX_DATA_WIDTH = 8)
  (
  // inputs
  input logic              i_clk,
  input logic              i_rst_n,
  input [ADDR_WIDTH-1:0]   i_lsu_addr,
  input [2:0]              i_func,
   
  input logic              i_lsu_wren,
  input [DATA_WIDTH-1: 0] 	i_st_data,
  input [DATA_WIDTH-1: 0] 	i_io_sw, // switch data
  input [DATA_WIDTH-1: 0] 	i_io_btn, // button data
  // outputs
  output [DATA_WIDTH-1:0]  o_ld_data,
  output [DATA_WIDTH-1:0] 	o_io_lcd,
  output [DATA_WIDTH-1:0] 	o_io_ledg,
  output [DATA_WIDTH-1:0]  o_io_ledr,
  
  output [HEX_DATA_WIDTH-1:0]  o_io_hex0,
  output [HEX_DATA_WIDTH-1:0]  o_io_hex1,
  output [HEX_DATA_WIDTH-1:0]  o_io_hex2,
  output [HEX_DATA_WIDTH-1:0]  o_io_hex3,
  output [HEX_DATA_WIDTH-1:0]  o_io_hex4,
  output [HEX_DATA_WIDTH-1:0]  o_io_hex5,
  output [HEX_DATA_WIDTH-1:0]  o_io_hex6,
  output [HEX_DATA_WIDTH-1:0]  o_io_hex7
);
  wire [5:0] true_addr = i_lsu_addr[5:0];
  wire [3:0] bank_sel = i_lsu_addr[14:11];
  wire [DATA_WIDTH-1: 0] ld_data_ip;
  wire [DATA_WIDTH-1: 0] o_ld_datap;
  wire [DATA_WIDTH-1: 0] ld_data_d;
							 
// input perripherals mem
  lsu_2d_ip_bank lsu_2d_ip(
    .i_clk    (i_clk),
    .i_rst_n  (i_rst_n),	
    .pi_lsu_addr  (true_addr),
    .penable_i(bank_sel == 4'hF), //x7800
    .pfunct_code_i	(i_func),
    .pwdata_i_1 (i_io_sw),
    .pwdata_i_2 (i_io_btn),
    .prdata_o (ld_data_ip)
	);

// output perripherals mem
  lsu_2d_op_bank lsu_2d_op(
    .i_clk     (i_clk),
    .i_rst_n   (i_rst_n),
    .pi_lsu_addr   (true_addr),
    .penable_i (bank_sel == 4'hE), //x7000
    .pfunct_code_i	(i_func),
    .pwrite_i  (i_lsu_wren),
    .pwdata_i  (i_st_data),
		
    .prdata_o  (o_ld_datap),	
    .o_io_lcd  (o_io_lcd),
    .o_io_ledg (o_io_ledg),
    .o_io_ledr (o_io_ledr),	
    .o_io_hex0 (o_io_hex0),
    .o_io_hex1	(o_io_hex1),
    .o_io_hex2	(o_io_hex2),
    .o_io_hex3	(o_io_hex3),
    .o_io_hex4	(o_io_hex4),
    .o_io_hex5	(o_io_hex5),
    .o_io_hex6	(o_io_hex6),
    .o_io_hex7	(o_io_hex7)
  );
	
// D mem
  lsu_2d_bank lsu_2d_dmem(
    .i_clk     (i_clk),
    .i_rst_n   (i_rst_n),
    .pi_lsu_addr   (i_lsu_addr[12:0]),
    .penable_i	(bank_sel == 4'h4 || bank_sel == 4'h5 || bank_sel == 4'h6 || bank_sel == 4'h7),	//x2000 -> x3FFF
    .pwrite_i  (i_lsu_wren),
    .pwdata_i  (i_st_data),
	 .pfunct_code_i	(i_func),
 
    .prdata_o  (ld_data_d)
  );
	
  assign o_ld_data = (bank_sel == 4'h4 || bank_sel == 4'h5 || bank_sel == 4'h6 || bank_sel == 4'h7)  ? ld_data_d  :
                     ((bank_sel 		 == 4'hE) ? o_ld_datap :
                     ((bank_sel 		 == 4'hF) ? ld_data_ip : 'z));

 

endmodule 
