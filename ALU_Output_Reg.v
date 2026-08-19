module ALU_OUTPUT_REG (
    input clk,
    input rst,
    input [31:0] ALU_OUTPUT_atALU,

    output reg [31:0] ALU_REG_OUT
);

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            ALU_REG_OUT <= 32'b0;
        end
        else
            ALU_REG_OUT <= ALU_OUTPUT_atALU;
    end
    
endmodule