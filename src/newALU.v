module ALU (
    input [31:0] srcA,
    input [31:0] srcB,

    input [4:0] ALU_OP_SELECT_atALU,

    output reg [31:0] ALU_OUTPUT_atALU
);

    wire [4:0] SHIFT_AMOUNT = srcB[4:0];

    wire IS_REG_IMM = ALU_OP_SELECT_atALU[3];

    wire [2:0] funct3 = ALU_OP_SELECT_atALU[2:0];



    wire [31:0] CLU_OUTPUT;
    wire CLU_CARRY_OUT;

    wire IS_SLT = (funct3 == 3'b011) | (funct3 == 3'b010);
    wire IS_SUB = (!IS_REG_IMM) && ALU_OP_SELECT_atALU[4];

    wire IS_SUB_OR_SLT = IS_SUB | IS_SLT;

    wire [31:0] OPERAND_B = IS_SUB_OR_SLT ? ~srcB : srcB;

    wire OVERFLOW = ~(srcA[31] ^ OPERAND_B[31]) & (srcA[31] ^ CLU_OUTPUT[31]);
    wire SLT = CLU_OUTPUT[31] ^ OVERFLOW;
    
    CLU CLA(
        .operand1(srcA),
        .operand2(OPERAND_B),
        .top_carry_in(IS_SUB_OR_SLT),
        .CLU_OUTPUT(CLU_OUTPUT),
        .top_carry_out(CLU_CARRY_OUT)
    );

    always @(*) begin
        
        ALU_OUTPUT_atALU = 32'b0;

        case (funct3)

                    3'b000: begin // ADDI, ADD and SUB
                        ALU_OUTPUT_atALU = CLU_OUTPUT;
                    end

                    3'b001: begin 
                        ALU_OUTPUT_atALU = srcA << srcB[4:0]; //SLLI and SLL
                    end

                    3'b010: begin 
                        ALU_OUTPUT_atALU = {31'b0, SLT}; //SLTI and SLT
                    end

                    3'b011: begin 
                        ALU_OUTPUT_atALU = {31'b0, ~CLU_CARRY_OUT}; //SLTUI and SLTU
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