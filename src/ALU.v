module ALU (
    input [31:0] srcA,
    input [31:0] srcB,

    input [4:0] ALU_OP_SELECT_atALU,

    output reg [31:0] ALU_OUTPUT_atALU
);
    
    wire [4:0] SHIFT_AMOUNT = srcB[4:0];

    wire IS_REG_IMM = ALU_OP_SELECT_atALU[3];

    wire [2:0] funct3 = ALU_OP_SELECT_atALU[2:0];

    wire IS_SUB = (!IS_REG_IMM) && ALU_OP_SELECT_atALU[4];
    wire [31:0] OPERAND_B = IS_SUB ? ~srcB : srcB;
    wire [31:0] ADD_SUB_RESULT = srcA + OPERAND_B + IS_SUB;

    always @(*) begin
        
        ALU_OUTPUT_atALU = 32'b0;

        case (funct3)

                    3'b000: begin // ADDI, ADD and SUB
                            ALU_OUTPUT_atALU = ADD_SUB_RESULT;
                    end

                    3'b001: begin 
                        ALU_OUTPUT_atALU = $signed(srcA) << srcB[4:0]; //SLLI and SLL
                    end

                    3'b010: begin 
                        ALU_OUTPUT_atALU = {31'b0, $signed(srcA) < $signed(srcB)}; //SLTI and SLTI
                    end

                    3'b011: begin 
                        ALU_OUTPUT_atALU = {31'b0, srcA < srcB}; //SLTUI and SLTU
                    end

                    3'b100: begin 
                        ALU_OUTPUT_atALU = srcA ^ srcB; //XORI and XOR
                    end

                    3'b101: begin //SRL/SRLI and SRA/SRAI

                        case (ALU_OP_SELECT_atALU[4])
                            1'b1: ALU_OUTPUT_atALU = $signed(srcA) >>> SHIFT_AMOUNT;
                            1'b0: ALU_OUTPUT_atALU = srcA >> SHIFT_AMOUNT;
                            default: ;
                        endcase

                    end

                    3'b110: begin 
                        ALU_OUTPUT_atALU = srcA | srcB; //OR
                    end

                    3'b111: begin 
                        ALU_OUTPUT_atALU = srcA & srcB; //AND
                    end

                    default: ALU_OUTPUT_atALU = 32'b0;
        endcase
    end

endmodule
