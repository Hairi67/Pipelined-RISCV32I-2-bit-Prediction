module instruction_check (
    input logic i_insn_vld,
    input logic i_clk, i_rst_n,
    output logic o_insn_vld
);

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_insn_vld <= 1'b0;
    end else begin
        o_insn_vld <= i_insn_vld;
    end

end

endmodule