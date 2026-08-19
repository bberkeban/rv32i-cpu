module CLU_4bit (
    input [3:0] X,
    input [3:0] Y,
    input C_in,

    output [3:0] Z,
    output C_out,
    output P_G,
    output G_G
);

    wire [3:0] C;
    wire [3:0] G = X & Y;
    wire [3:0] P = X ^ Y;

    assign C[0] = (C_in & P[0]) | G[0];
    assign C[1] = G[1] | (P[1] & P[0] & C_in) | (P[1] & G[0]);
    assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C_in);
    assign C[3] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C_in);

    assign C_out = C[3];

    assign Z = P ^ {C[2:0], C_in};
    assign P_G = &P;
    assign G_G = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);

endmodule

module CLU_16bit (
    input [15:0] A,
    input [15:0] B,

    input carry_in,

    output [15:0] OUT,
    output carry_out,
    output P_super,
    output G_super
);

    wire [3:1] carry;
    wire [3:0] P_group;
    wire [3:0] G_group;

    assign carry[1] = G_group[0] | (P_group[0] & carry_in);
    assign carry[2] = G_group[1] | (P_group[1] & G_group[0]) | (P_group[1] & P_group[0] & carry_in);
    assign carry[3] = G_group[2] | (P_group[2] & G_group[1]) | (P_group[2] & P_group[1] & G_group[0]) | (P_group[2] & P_group[1] & P_group[0] & carry_in);

    wire P_s = &P_group;
    wire G_s = G_group[3] | (P_group[3] & G_group[2]) | (P_group[3] & P_group[2] & G_group[1]) | (P_group[3] & P_group[2] & P_group[1] & G_group[0]);

    CLU_4bit CLA1(
        .X(A[3:0]),
        .Y(B[3:0]),
        .C_in(carry_in),
        .Z(OUT[3:0]),
        .C_out(),
        .P_G(P_group[0]),
        .G_G(G_group[0])
    );
    CLU_4bit CLA2(
        .X(A[7:4]),
        .Y(B[7:4]),
        .C_in(carry[1]),
        .Z(OUT[7:4]),
        .C_out(),
        .P_G(P_group[1]),
        .G_G(G_group[1])
    );
    CLU_4bit CLA3(
        .X(A[11:8]),
        .Y(B[11:8]),
        .C_in(carry[2]),
        .Z(OUT[11:8]),
        .C_out(),
        .P_G(P_group[2]),
        .G_G(G_group[2])
    );
    CLU_4bit CLA4(
        .X(A[15:12]),
        .Y(B[15:12]),
        .C_in(carry[3]),
        .Z(OUT[15:12]),
        .C_out(),
        .P_G(P_group[3]),
        .G_G(G_group[3])
    );

    assign carry_out = (P_s & carry_in) | G_s;

    assign P_super = P_s;
    assign G_super = G_s;

endmodule

module CLU (
    input [31:0] operand1,
    input [31:0] operand2,

    input top_carry_in,

    output [31:0] CLU_OUTPUT,
    output top_carry_out
);
    wire the_carry;

    CLU_16bit LCU1(
        .A(operand1[15:0]),
        .B(operand2[15:0]),
        .carry_in(top_carry_in),
        .OUT(CLU_OUTPUT[15:0]),
        .carry_out(the_carry),
        .P_super(),
        .G_super()
    );

    CLU_16bit LCU2(
        .A(operand1[31:16]),
        .B(operand2[31:16]),
        .carry_in(the_carry),
        .OUT(CLU_OUTPUT[31:16]),
        .carry_out(top_carry_out),
        .P_super(),
        .G_super()
    );

endmodule