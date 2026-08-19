module A_and_B (
    input clk,
    input rst,

    input [31:0] inputA,
    input [31:0] inputB,

    output reg [31:0] outputA,
    output reg [31:0] outputB
);

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            outputA <= 32'b0;
            outputB <= 32'b0;
        end
        else
            outputA <= inputA;
            outputB <= inputB;
    end
    
endmodule