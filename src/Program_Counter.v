module PC (
    input clk,
    input rst,

    input [31:0] PC_LOAD_DATA,
    input FINALIZED_PC_LOAD_ENABLE,
    input PC_COUNT_UP,

    output reg [31:0] PC,
    output reg [31:0] OLD_PC
);

    wire [31:0] INCREMENTED_PC = PC + 4;

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            PC <= 32'b0;
            OLD_PC <= 32'b0;
        end
        else if (FINALIZED_PC_LOAD_ENABLE == 1'b1) begin
            PC <= PC_LOAD_DATA;
        end
        else if (PC_COUNT_UP == 1'b1) begin
            PC <= INCREMENTED_PC;
            OLD_PC <= PC;
        end
    end

    
endmodule