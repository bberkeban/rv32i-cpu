module ALU_SVA (
    input [31:0] srcA,
    input [31:0] srcB,

    input [4:0] ALU_OP_SELECT_atALU,

    output [31:0] ALU_OUTPUT_atALU
);

    ALU UUT(
        .srcA(srcA),
        .srcB(srcB),
        .ALU_OP_SELECT_atALU(ALU_OP_SELECT_atALU),
        .ALU_OUTPUT_atALU(ALU_OUTPUT_atALU)
    );

    wire [4:0] SHIFT_AMOUNT = srcB[4:0];
    
    wire [2:0] funct3 = ALU_OP_SELECT_atALU[2:0];
    wire IS_REG_IMM = ALU_OP_SELECT_atALU[3];

    always @(*) begin
        case (funct3)
            3'b000: begin
                case (IS_REG_IMM)
                    1'b1: begin
                        assert(ALU_OUTPUT_atALU == (srcA + srcB));
                    end
                    1'b0: begin
                        case (ALU_OP_SELECT_atALU[4])
                            1'b1: begin
                                assert(ALU_OUTPUT_atALU == (srcA - srcB));
                            end
                            1'b0: begin
                                assert(ALU_OUTPUT_atALU == (srcA + srcB));
                            end
                        endcase
                    end
                endcase
            end
            3'b001: begin
                assert(ALU_OUTPUT_atALU == srcA << srcB[4:0]);
            end
            3'b010: begin
                assert(ALU_OUTPUT_atALU == {31'b0, $signed(srcA) < $signed(srcB)});
            end
            3'b011: begin
                assert(ALU_OUTPUT_atALU == {31'b0, srcA < srcB});
            end
            3'b100: begin
                assert(ALU_OUTPUT_atALU == (srcA ^ srcB));
            end
            3'b101: begin
                case (ALU_OP_SELECT_atALU[4])
                        1'b1: assert(ALU_OUTPUT_atALU == $unsigned(($signed(srcA) >>> SHIFT_AMOUNT)));
                        1'b0: assert(ALU_OUTPUT_atALU == (srcA >> SHIFT_AMOUNT));  
                endcase
            end
            3'b110: begin
                assert(ALU_OUTPUT_atALU == (srcA | srcB));
            end
            3'b111: begin
                assert(ALU_OUTPUT_atALU == (srcA & srcB));
            end
        endcase
    end
endmodule