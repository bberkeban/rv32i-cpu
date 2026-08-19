module Branch_Unit (
    input [31:0] rs1,
    input [31:0] rs2,

    input [2:0] CONDITION_SELECT,

    output reg BRANCH_TAKEN
);
    
    wire IS_EQUAL  = (rs1 == rs2);
    wire IS_LESS   = ($signed(rs1) < $signed(rs2));
    wire IS_LESS_U = (rs1 < rs2);

    always @(*) begin
        
        BRANCH_TAKEN = 1'b0;

        case (CONDITION_SELECT)

            3'b000: BRANCH_TAKEN = IS_EQUAL;
            3'b001: BRANCH_TAKEN = ~IS_EQUAL;

            3'b100: BRANCH_TAKEN = IS_LESS;
            3'b101: BRANCH_TAKEN = ~IS_LESS;

            3'b110: BRANCH_TAKEN = IS_LESS_U;
            3'b111: BRANCH_TAKEN = ~IS_LESS_U;

            default: BRANCH_TAKEN = 1'b0;
        endcase
    end

endmodule