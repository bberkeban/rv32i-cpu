module Load_Store_Unit(
    input [2:0] LOAD_STORE_CONTROL,

    input [31:0] MEMORY_DATA_ADDRESS_LSU,

    input [31:0] RAW_MEMORY_READ_DATA, 

    input [31:0] RAW_MEMORY_WRITE_DATA, //rs2

    output reg [3:0] STORE_BYTE_CONTROL,
    output reg [31:0] MEMORY_WRITE_DATA,
    output reg [31:0] BIT_ALIGNED_MEMORY_READ_DATA //rd

);
    
    wire [1:0] ADDRESS_OFFSET = MEMORY_DATA_ADDRESS_LSU[1:0];

    always @(*) begin

        BIT_ALIGNED_MEMORY_READ_DATA = 32'b0;
        STORE_BYTE_CONTROL = 4'b0000;
        MEMORY_WRITE_DATA = 32'b0;
        
        case (LOAD_STORE_CONTROL)

            3'b000: begin //LB and SB

                MEMORY_WRITE_DATA = {4{RAW_MEMORY_WRITE_DATA[7:0]}};

                case (ADDRESS_OFFSET)
                    2'b00: begin 
                        BIT_ALIGNED_MEMORY_READ_DATA = {{24{RAW_MEMORY_READ_DATA[7]}}, RAW_MEMORY_READ_DATA[7:0]};
                        STORE_BYTE_CONTROL = 4'b0001;
                    end
                    2'b01: begin 
                        BIT_ALIGNED_MEMORY_READ_DATA = {{24{RAW_MEMORY_READ_DATA[15]}}, RAW_MEMORY_READ_DATA[15:8]};
                        STORE_BYTE_CONTROL = 4'b0010;
                    end
                    2'b10: begin 
                        BIT_ALIGNED_MEMORY_READ_DATA = {{24{RAW_MEMORY_READ_DATA[23]}}, RAW_MEMORY_READ_DATA[23:16]};
                        STORE_BYTE_CONTROL = 4'b0100;
                    end
                    2'b11: begin 
                        BIT_ALIGNED_MEMORY_READ_DATA = {{24{RAW_MEMORY_READ_DATA[31]}}, RAW_MEMORY_READ_DATA[31:24]};
                        STORE_BYTE_CONTROL = 4'b1000;
                    end
                endcase
            end

            3'b001: begin //LH and SH

            MEMORY_WRITE_DATA = {2{RAW_MEMORY_WRITE_DATA[15:0]}};

                case (ADDRESS_OFFSET[1])
                    1'b0: begin 
                        BIT_ALIGNED_MEMORY_READ_DATA = {{16{RAW_MEMORY_READ_DATA[15]}}, RAW_MEMORY_READ_DATA[15:0]};
                        STORE_BYTE_CONTROL = 4'b0011;
                    end
                    1'b1: begin 
                        BIT_ALIGNED_MEMORY_READ_DATA = {{16{RAW_MEMORY_READ_DATA[31]}}, RAW_MEMORY_READ_DATA[31:16]};
                        STORE_BYTE_CONTROL = 4'b1100;
                    end
                endcase
            end

            3'b010: begin //LW and SW
                BIT_ALIGNED_MEMORY_READ_DATA = RAW_MEMORY_READ_DATA;
                MEMORY_WRITE_DATA = RAW_MEMORY_WRITE_DATA;
                STORE_BYTE_CONTROL = 4'b1111;
            end

            3'b100: begin //LBU
                case (ADDRESS_OFFSET)
                    2'b00: BIT_ALIGNED_MEMORY_READ_DATA = {24'b0, RAW_MEMORY_READ_DATA[7:0]};
                    2'b01: BIT_ALIGNED_MEMORY_READ_DATA = {24'b0, RAW_MEMORY_READ_DATA[15:8]};
                    2'b10: BIT_ALIGNED_MEMORY_READ_DATA = {24'b0, RAW_MEMORY_READ_DATA[23:16]};
                    2'b11: BIT_ALIGNED_MEMORY_READ_DATA = {24'b0, RAW_MEMORY_READ_DATA[31:24]}; 
                endcase
            end

            3'b101: begin 
                case (ADDRESS_OFFSET[1])
                    1'b0: BIT_ALIGNED_MEMORY_READ_DATA = {16'b0, RAW_MEMORY_READ_DATA[15:0]};
                    1'b1: BIT_ALIGNED_MEMORY_READ_DATA = {16'b0, RAW_MEMORY_READ_DATA[31:16]};
                endcase
            end

            default: begin 
                BIT_ALIGNED_MEMORY_READ_DATA = 32'b0;
                MEMORY_WRITE_DATA = 32'b0;
                STORE_BYTE_CONTROL = 4'b0000;
            end
        endcase
    end

endmodule