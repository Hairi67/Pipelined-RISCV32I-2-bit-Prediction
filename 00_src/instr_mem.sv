module instr_mem
#(parameter WIDTH = 32)
(
    input logic  [WIDTH-1:0] i_address,   
    output logic [WIDTH-1:0] o_instr      
);

   
    logic [31:0] rom [0:500];

    
    initial begin
        $readmemh("../02_test/instruction.hex", rom);  // Load hex file 
    end

    // Combinational read block
    always_comb begin
        o_instr = rom[i_address[31:2]];  
    end

endmodule
