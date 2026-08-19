module Register_File (
    input clk,
    input rst,

    input [31:0] RF_WRITE_DATA,

    input RF_WRITE_ENABLE,

    input [4:0] RF_READ_SELECT_1,
    input [4:0] RF_READ_SELECT_2,
    
    input [4:0] RF_WRITE_SELECT,

    output [31:0] RF_READ_DATA_1,
    output [31:0] RF_READ_DATA_2
);

    integer i;

    reg [31:0] registers [1:31];

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            for (i = 1; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end

        else if (RF_WRITE_ENABLE == 1'b1 && !(RF_WRITE_SELECT == 5'b0)) begin
            registers[RF_WRITE_SELECT] <= RF_WRITE_DATA;
        end
    end

    assign RF_READ_DATA_1 = !(RF_READ_SELECT_1 == 5'b0) ? registers[RF_READ_SELECT_1] : 32'b0;
    assign RF_READ_DATA_2 = !(RF_READ_SELECT_2 == 5'b0) ? registers[RF_READ_SELECT_2] : 32'b0;
    
endmodule