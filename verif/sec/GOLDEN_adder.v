module CLU_EQV (
    input [31:0] operand1,
    input [31:0] operand2,
    input top_carry_in,

    output top_carry_out,
    output [31:0] CLU_OUTPUT
);

    assign {top_carry_out, CLU_OUTPUT} = operand1 + operand2 + top_carry_in;
    
endmodule