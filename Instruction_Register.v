module IR (
    input clk,
    input rst,
    input IR_ENABLE,

    input [31:0] instruction_IR,
    output reg [31:0] IR
);

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            IR <= 32'b0;
        end
        else if (IR_ENABLE == 1'b1) begin
            IR <= instruction_IR;
        end
    end
    
endmodule