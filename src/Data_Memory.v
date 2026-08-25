module Data_Memory #(
    parameter WORDS = 4096
)

(
    input clk,

    input [3:0] STORE_BYTE_CONTROL,
    input [31:0] MEMORY_WRITE_DATA,
    input [31:0] MEMORY_DATA_ADDRESS,

    input MEM_READ_ENABLE,
    input MEM_WRITE_ENABLE,

    output reg [31:0] RAW_MEMORY_READ_DATA
);
    
    reg [31:0] memory [0:WORDS-1];

    initial begin
        $readmemh("instructions.txt", memory);
    end

    wire [$clog2(WORDS)-1:0] WORD_ADDRESS = MEMORY_DATA_ADDRESS[$clog2(WORDS)+1:2];

    always @(posedge clk) begin
        if (MEM_READ_ENABLE == 1'b1) begin
            RAW_MEMORY_READ_DATA <= memory[WORD_ADDRESS];
        end
        else if (MEM_WRITE_ENABLE == 1'b1) begin
                if (STORE_BYTE_CONTROL[0] == 1'b1) memory[WORD_ADDRESS][7:0] <= MEMORY_WRITE_DATA[7:0];
                if (STORE_BYTE_CONTROL[1] == 1'b1) memory[WORD_ADDRESS][15:8] <= MEMORY_WRITE_DATA[15:8];
                if (STORE_BYTE_CONTROL[2] == 1'b1) memory[WORD_ADDRESS][23:16] <= MEMORY_WRITE_DATA[23:16];
                if (STORE_BYTE_CONTROL[3] == 1'b1) memory[WORD_ADDRESS][31:24] <= MEMORY_WRITE_DATA[31:24];
        end
    end
endmodule