module ControlUnit (
    input clk,
    input rst,

    input [31:0] IR,
    output reg [31:0] immediate,

    //control signals:

    //register file control
    output reg RF_WRITE_ENABLE,
    output [4:0] RF_READ_SELECT_1,
    output [4:0] RF_READ_SELECT_2,
    output [4:0] RF_WRITE_SELECT,

    output reg [1:0] RF_WB_MUX_SELECT, //00 ALU_OUTPUT, 01 MDR, 10 PC + 4, 11 NOT USED
    
    //ALU control:
    output reg [4:0] ALU_OP_SELECT, // {ARITHMETIC/LOGIC, R-R/R-IMM, funct3}
    // ALU operations: ADD, SUB, SLL/SRL -Logic Shift Left/Right-,
    // SRA -Arithmetic Shift Right-, AND, OR, XOR
    // SLT -Signed "Set Lesser Than", SLTU -Unsigned SLT
    output reg [1:0] ALU_SRC_A_SELECT, // 00 rs1, 01 PC, 11 32'b0
    output reg ALU_SRC_B_SELECT, // 0 rs2, 1 imm

    //Program Counter control:

    output reg PC_LOAD,
    output reg PC_COUNT_UP,
    output reg PC_LOAD_DATA_SELECT, //0 branch, 1 jalr/jal(ALU_OUT)

    //MEMORY control
    output reg MEM_READ_ENABLE,
    output reg MEM_WRITE_ENABLE,
    output [2:0] LOAD_STORE_CONTROL,

    //BRANCH control
    output reg IS_BRANCH,
    output [2:0] CONDITION_SELECT,

    output reg IR_ENABLE

);

    reg [2:0] states;

    localparam [2:0]
        FETCH           = 3'b000,
        DECODE          = 3'b001,
        EXECUTE         = 3'b011,
        REG_WRITE       = 3'b111,
        MEM_READ        = 3'b110,
        MEM_WRITE       = 3'b010,
        EXECUTE_BRANCH  = 3'b100;

    assign RF_READ_SELECT_1 = IR[19:15];    //rs1
    assign RF_READ_SELECT_2 = IR[24:20];    //rs2
    assign RF_WRITE_SELECT  = IR[11:7];     //rd


    wire [6:0] funct7 = IR[31:25];
    wire [2:0] funct3 = IR[14:12];
    wire [6:0] opcode = IR[6:0];

    wire [11:0] imm_I_raw = IR[31:20];
    wire [11:0] imm_S_raw = {IR[31:25], IR[11:7]};
    wire [19:0] imm_U_raw = IR[31:12];
    wire [11:0] imm_B_raw = {IR[31], IR[7], IR[30:25], IR[11:8]};
    wire [19:0] imm_J_raw = {IR[31], IR[19:12], IR[20], IR[30:21]};

    always @(*) begin //immediate generator

        immediate = 32'd0;

        case (opcode)

            7'b0010011,
            7'b0000011,
            7'b1100111: begin
                immediate = {{20{imm_I_raw[11]}}, imm_I_raw};
            end

            7'b0100011: begin
                immediate = {{20{imm_S_raw[11]}}, imm_S_raw};
            end

            7'b0110111,
            7'b0010111: begin
                immediate = {imm_U_raw, 12'b0};
            end

            7'b1100011: begin
                immediate = {{19{imm_B_raw[11]}}, imm_B_raw, 1'b0};
            end

            7'b1101111: begin
                immediate = {{11{imm_J_raw[19]}}, imm_J_raw, 1'b0};
            end

            default: immediate = 32'd0;
        endcase
    end

    always @(posedge clk or posedge rst) begin //fsm
        if (rst == 1'b1) begin
            states <= 3'b000;
        end
        else 
            case (states)

            FETCH: states <= DECODE;

            DECODE: begin
                if (opcode == 7'b1100011) begin
                    states <= EXECUTE_BRANCH;
                end
                else
                    states <= EXECUTE;
            end

            EXECUTE_BRANCH: states <= FETCH;

            EXECUTE: begin
                if (opcode == 7'b0100011) begin
                    states <= MEM_WRITE;
                end
                else if (opcode == 7'b0000011) begin
                    states <= MEM_READ;
                end
                else
                    states <= REG_WRITE;
            end

            MEM_READ: states <= REG_WRITE;
        
            MEM_WRITE: states <= FETCH;

            REG_WRITE: states <= FETCH;

            default: states <= FETCH;
        endcase
    end


    always @(*) begin //control generator

        PC_COUNT_UP = 1'b0;
        PC_LOAD = 1'b0;
        PC_LOAD_DATA_SELECT = 1'b0;

        MEM_READ_ENABLE = 1'b0;
        MEM_WRITE_ENABLE = 1'b0;

        RF_WRITE_ENABLE = 1'b0;
        RF_WB_MUX_SELECT = 2'b0;

        ALU_OP_SELECT = 5'b0;
        ALU_SRC_A_SELECT = 2'b0;
        ALU_SRC_B_SELECT = 1'b0;

        IR_ENABLE = 1'b1;

        case (states)

            FETCH: begin 
                PC_COUNT_UP = 1'b1;
                IR_ENABLE = 1'b1;
            end

            EXECUTE: begin
                case (opcode)

                    7'b0010011: begin // Register-Immediate ALU
                        ALU_OP_SELECT = {funct7[5], 1'b1, funct3};
                        ALU_SRC_A_SELECT = 2'b0;
                        ALU_SRC_B_SELECT = 1'b1;
                    end 

                    7'b0110011: begin // Register-Register ALU

                            ALU_OP_SELECT = {funct7[5], 1'b0, funct3};
                            ALU_SRC_A_SELECT = 2'b0; 
                            ALU_SRC_B_SELECT = 1'b0; // funct7 = 7'h00 or any funct7 -> ALU_OP_SELECT[4] = 1'b0
                    end

                    7'b0000011, //load
                    7'b0100011: begin //store
                        ALU_OP_SELECT = {1'b0, 1'b1, 3'b000};
                        ALU_SRC_A_SELECT = 2'b0;
                        ALU_SRC_B_SELECT = 1'b1;
                    end

                    7'b1101111: begin //JAL
                        ALU_OP_SELECT = {1'b0, 1'b1, 3'b000};
                        ALU_SRC_A_SELECT = 2'b01; //PC
                        ALU_SRC_B_SELECT = 1'b1; //IMM
                    end

                    7'b1100111: begin //JALR
                        ALU_OP_SELECT = {1'b0, 1'b1, 3'b000};
                        ALU_SRC_A_SELECT = 2'b0; //RF
                        ALU_SRC_B_SELECT = 1'b1; //IMM
                    end 

                    7'b0010111, //AUIPC
                    7'b0110111: begin //LUI
                        ALU_OP_SELECT = {1'b0, 1'b1, 3'b000};
                        ALU_SRC_A_SELECT = {opcode[6], 1'b1};
                        ALU_SRC_B_SELECT = 1'b1;
                    end

                    default: ALU_OP_SELECT = 5'b0;
                endcase
            end

            EXECUTE_BRANCH: begin
                PC_LOAD_DATA_SELECT = 1'b0;
                IS_BRANCH = 1'b1;
            end

            MEM_READ: begin 

                MEM_READ_ENABLE = 1'b1;

            end

            MEM_WRITE: begin

                MEM_WRITE_ENABLE = 1'b1;


            end

            REG_WRITE: begin
                
                RF_WRITE_ENABLE = 1'b1;

                case (opcode)
                    7'b0110111, //LUI
                    7'b0010111, //AUIPC
                    7'b0010011, //I-R Type
                    7'b0110011: begin //R-R Type
                        RF_WB_MUX_SELECT = 2'b00;
                    end

                    7'b1101111, //JAL
                    7'b1100111: begin //JALR
                        RF_WB_MUX_SELECT = 2'b10;
                        PC_LOAD = 1'b1;
                        PC_LOAD_DATA_SELECT = 1'b1;
                    end

                    7'b0000011: RF_WB_MUX_SELECT = 2'b01; //LOAD
                
                    default: RF_WB_MUX_SELECT = 2'b00;
                endcase

            end

            default: ;

        endcase
    end

    assign CONDITION_SELECT = funct3;
    assign LOAD_STORE_CONTROL = funct3;

endmodule