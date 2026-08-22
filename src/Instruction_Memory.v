module Instruction_Memory #(
    parameter WORDS = 1024
)

(
    input clk,
    input [31:0] PC,

    output reg [31:0] Instruction
);
    
    reg [31:0] I_MEM [0:WORDS-1];

    initial begin
        $readmemh("instructions.txt", I_MEM);
    end

    wire [$clog2(WORDS)-1:0] word_addr = PC[$clog2(WORDS)+1:2];

    always @(posedge clk) begin
        Instruction <= I_MEM[word_addr];
    end
endmodule