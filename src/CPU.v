module CPU (
    input clk,
    input rst,

    output [31:0] ALU_debug,
    output [31:0] RF_debug,
    output [31:0] PC_debug,
    output [31:0] MEM_debug
);
    // IR I/O WIRE SECTION
    wire [31:0] instruction_to_IR;
    wire [31:0] IR;

    wire [6:0] opcode = IR[6:0];
    wire IR_ENABLE;
    //IR SECTION END

    // Control Unit I/O WIRE SECTION
    wire [31:0] immediate;
    wire PC_LOAD_ENABLE;
    wire IS_BRANCH;
    wire PC_LOAD_DATA_SELECT;
    // Control Unit SECTION END

    // Branch Unit I/O WIRE SECTION
    wire [2:0] CONDITION_SELECT;
    wire BRANCH_TAKEN;
    // Branch Unit I/O WIRE SECTION

    // Memory I/O WIRE SECTION
    wire MEM_READ_ENABLE;
    wire MEM_WRITE_ENABLE;
    // Memory SECTION END

    // RF I/O WIRE SECTION
    wire RF_WRITE_ENABLE;
    wire [4:0] RF_READ_SELECT_1;
    wire [4:0] RF_READ_SELECT_2;
    wire [4:0] RF_WRITE_SELECT;

    wire [31:0] RF_READ_DATA_1;
    wire [31:0] RF_READ_DATA_2;
    reg [31:0] RF_WRITE_DATA;

    wire [1:0] RF_WB_MUX_SELECT;
    // RF SECTION END

    // Branch Target I/O WIRE SECTION
    wire [31:0] Branch_Target;
    // Branch Target I/O SECTION END

     // ALU I/O WIRE SECTION
    reg [31:0] srcA;
    reg [31:0] srcB;
    wire [4:0] ALU_OP_SELECT_atALU;
    wire [31:0] ALU_OUTPUT;

    wire [1:0] ALU_SRC_A_SELECT;
    wire ALU_SRC_B_SELECT;

    wire [31:0] ALU_REG_OUT;
    // ALU SECTION END

    // PC I/O WIRE SECTION
    reg [31:0] PC_LOAD_DATA;
    wire FINALIZED_PC_LOAD_ENABLE;
    wire PC_COUNT_UP;
    wire [31:0] PC;
    wire [31:0] OLD_PC;

    wire [31:0] ALU_OUTPUT_TO_PC;
    assign ALU_OUTPUT_TO_PC = (opcode == 7'b1100111) ? (ALU_REG_OUT & ~32'd1) : ALU_REG_OUT;
    
    wire PC_IS_ALIGNED;
    assign PC_IS_ALIGNED = ~|PC_LOAD_DATA[1:0];


    assign FINALIZED_PC_LOAD_ENABLE = PC_IS_ALIGNED & (PC_LOAD_ENABLE | (IS_BRANCH & BRANCH_TAKEN));
    // PC SECTION END

    
    // INTERNAL WIRE SECTION
    wire [31:0] A;
    wire [31:0] B;
    // INTERNAL SECTION END


    // LSU I/O WIRE SECTION
    wire [2:0] LOAD_STORE_CONTROL;
    wire [31:0] MEMORY_DATA_ADDRESS;
    wire [31:0] RAW_MEMORY_READ_DATA;
    wire [31:0] RAW_MEMORY_WRITE_DATA;
    wire [3:0] STORE_BYTE_CONTROL;
    wire [31:0] MEMORY_WRITE_DATA;
    wire [31:0] BIT_ALIGNED_MEMORY_READ_DATA;
    // LSU SECTION END

    // MUXES
    always @(*) begin
        PC_LOAD_DATA = 32'b0;
        case (PC_LOAD_DATA_SELECT)
            1'b0: PC_LOAD_DATA = Branch_Target;
            1'b1: PC_LOAD_DATA = ALU_OUTPUT_TO_PC;
        endcase
    end

    always @(*) begin
        srcA = 32'b0;
        case (ALU_SRC_A_SELECT)
            2'b00: srcA = A;
            2'b01: srcA = OLD_PC;
            2'b11: srcA =  32'b0;
            default: srcA = 32'b0;
        endcase
    end

    always @(*) begin
        srcB = 32'b0;
        case (ALU_SRC_B_SELECT)
            1'b0: srcB = B;
            1'b1: srcB = immediate;
        endcase
    end

    always @(*) begin
        RF_WRITE_DATA = 32'b0;
        case (RF_WB_MUX_SELECT)
            2'b00: RF_WRITE_DATA = ALU_REG_OUT;
            2'b01: RF_WRITE_DATA = BIT_ALIGNED_MEMORY_READ_DATA;
            2'b10: RF_WRITE_DATA = PC;
            default: RF_WRITE_DATA = 32'b0;
        endcase
    end
    // MUXES SECTION END




    ControlUnit CU(
        .clk(clk),
        .rst(rst),

        .IR(IR),
        .immediate(immediate),

        .RF_WRITE_ENABLE(RF_WRITE_ENABLE),
        .RF_READ_SELECT_1(RF_READ_SELECT_1),
        .RF_READ_SELECT_2(RF_READ_SELECT_2),
        .RF_WRITE_SELECT(RF_WRITE_SELECT),

        .RF_WB_MUX_SELECT(RF_WB_MUX_SELECT),

        .ALU_OP_SELECT(ALU_OP_SELECT_atALU),
        .ALU_SRC_A_SELECT(ALU_SRC_A_SELECT),
        .ALU_SRC_B_SELECT(ALU_SRC_B_SELECT),

        .PC_LOAD(PC_LOAD_ENABLE),
        .PC_COUNT_UP(PC_COUNT_UP),
        .PC_LOAD_DATA_SELECT(PC_LOAD_DATA_SELECT),

        .MEM_READ_ENABLE(MEM_READ_ENABLE),
        .MEM_WRITE_ENABLE(MEM_WRITE_ENABLE),
        
        .LOAD_STORE_CONTROL(LOAD_STORE_CONTROL),

        .IS_BRANCH(IS_BRANCH),
        .CONDITION_SELECT(CONDITION_SELECT),

        .IR_ENABLE(IR_ENABLE)
    );

    Register_File RF(
        .clk(clk),
        .rst(rst),
        .RF_WRITE_DATA(RF_WRITE_DATA),
        .RF_WRITE_ENABLE(RF_WRITE_ENABLE),
        .RF_READ_SELECT_1(RF_READ_SELECT_1),
        .RF_READ_SELECT_2(RF_READ_SELECT_2),
        .RF_WRITE_SELECT(RF_WRITE_SELECT),
        .RF_READ_DATA_1(RF_READ_DATA_1),
        .RF_READ_DATA_2(RF_READ_DATA_2)
    );

    A_and_B A_B(
        .clk(clk),
        .rst(rst),
        .inputA(RF_READ_DATA_1),
        .inputB(RF_READ_DATA_2),
        .outputA(A),
        .outputB(B)
    );

    ALU_OUTPUT_REG ALU_REG(
        .clk(clk),
        .rst(rst),
        .ALU_OUTPUT_atALU(ALU_OUTPUT),
        .ALU_REG_OUT(ALU_REG_OUT)
    );

    ALU ALU(
        .srcA(srcA),
        .srcB(srcB),
        .ALU_OP_SELECT_atALU(ALU_OP_SELECT_atALU),
        .ALU_OUTPUT_atALU(ALU_OUTPUT)
    );

    Branch_Target BranchTarget(
        .PC(OLD_PC),
        .immediate(immediate),
        .Branch_Target(Branch_Target)
    );

    Branch_Unit BU(
        .rs1(A),
        .rs2(B),
        .CONDITION_SELECT(CONDITION_SELECT),
        .BRANCH_TAKEN(BRANCH_TAKEN)
    );

    Data_Memory MEM(
        .clk(clk),
        .STORE_BYTE_CONTROL(STORE_BYTE_CONTROL),
        .MEMORY_WRITE_DATA(MEMORY_WRITE_DATA),
        .MEMORY_DATA_ADDRESS(ALU_REG_OUT),
        .MEM_READ_ENABLE(MEM_READ_ENABLE),
        .MEM_WRITE_ENABLE(MEM_WRITE_ENABLE),
        .RAW_MEMORY_READ_DATA(RAW_MEMORY_READ_DATA)
    );

    Instruction_Memory IM(
        .clk(clk),
        .PC(PC),
        .Instruction(instruction_to_IR)
    );

    IR InstructionRegister(
        .clk(clk),
        .rst(rst),
        .instruction_IR(instruction_to_IR),
        .IR(IR),
        .IR_ENABLE(IR_ENABLE)
    );

    Load_Store_Unit LSU(
        .LOAD_STORE_CONTROL(LOAD_STORE_CONTROL),
        .MEMORY_DATA_ADDRESS_LSU(ALU_REG_OUT),
        .RAW_MEMORY_READ_DATA(RAW_MEMORY_READ_DATA),
        .RAW_MEMORY_WRITE_DATA(B),
        .STORE_BYTE_CONTROL(STORE_BYTE_CONTROL),
        .MEMORY_WRITE_DATA(MEMORY_WRITE_DATA),
        .BIT_ALIGNED_MEMORY_READ_DATA(BIT_ALIGNED_MEMORY_READ_DATA)
    );
    
    PC ProgramCounter(
        .clk(clk),
        .rst(rst),
        .PC_LOAD_DATA(PC_LOAD_DATA),
        .FINALIZED_PC_LOAD_ENABLE(FINALIZED_PC_LOAD_ENABLE),
        .PC_COUNT_UP(PC_COUNT_UP),
        .PC(PC),
        .OLD_PC(OLD_PC)
    );

    assign ALU_debug = ALU_REG_OUT;
    assign RF_debug  = RF_WRITE_DATA;
    assign PC_debug  = PC;
    assign MEM_debug = RAW_MEMORY_READ_DATA;

endmodule