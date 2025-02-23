`timescale 1ps/1ps

module hexled
  (
    input logic [7:0] i_data, //i_data
   output logic [6:0] o_hex //o_hex
   );

  always_comb begin
    unique case(i_data)
      8'd0: o_hex = 7'b1000000;
      8'd1: o_hex = 7'b1111001;
      8'd2: o_hex = 7'b0100100;
      8'd3: o_hex = 7'b0110000;
      8'd4: o_hex = 7'b0011001;
      8'd5: o_hex = 7'b0010010;
      8'd6: o_hex = 7'b0000010;
      8'd7: o_hex = 7'b1111000;
      8'd8: o_hex = 7'b0000000;
      8'd9: o_hex = 7'b0010000;
      8'hA: o_hex = 7'b0001000;
      8'hB: o_hex = 7'b0000011;
      8'hC: o_hex = 7'b1000110;
      8'hD: o_hex = 7'b0100001;
      8'hE: o_hex = 7'b0000110;
      8'hF: o_hex = 7'b0001110;
      default: o_hex = 7'b0111111;
    endcase
  end

endmodule

