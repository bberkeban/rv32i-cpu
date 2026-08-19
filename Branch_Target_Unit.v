module Branch_Target (
    input [31:0] PC,
    input [31:0] immediate,

    output [31:0] Branch_Target
);
    CLU CLA(
        .operand1(PC),
        .operand2(immediate),
        .top_carry_in(1'b0),
        .CLU_OUTPUT(Branch_Target),
        .top_carry_out()
    );
    
endmodule