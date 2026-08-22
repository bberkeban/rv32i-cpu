module CLU_SVA (
    input [31:0] operand1,
    input [31:0] operand2,
    input top_carry_in,

    output top_carry_out,
    output [31:0] CLU_OUTPUT
);
    
    CLU UUT(
        .operand1(operand1),
        .operand2(operand2),
        .top_carry_in(top_carry_in),
        .CLU_OUTPUT(CLU_OUTPUT),
        .top_carry_out(top_carry_out)
    );

    always @(*) begin
        assert ({top_carry_out, CLU_OUTPUT} == (operand1 + operand2 + top_carry_in));
    end


endmodule