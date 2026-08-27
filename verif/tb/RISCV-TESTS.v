module RISCV_TESTS_TB;
    reg clk;
    reg rst;

    wire [31:0] ALU_debug;
    wire [31:0] RF_debug;
    wire [31:0] PC_debug;
    wire [31:0] MEM_debug;

    integer cycle;

    wire [31:0] X3 = UUT.RF.registers[3];

    CPU UUT(
        .clk(clk),
        .rst(rst),
        .ALU_debug(ALU_debug),
        .RF_debug(RF_debug),
        .PC_debug(PC_debug),
        .MEM_debug(MEM_debug)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, RISCV_TESTS_TB);
        
        cycle = 0;
        rst = 1'b1;

        #20 rst = 1'b0;
    end

    always @(posedge clk) begin
        if (rst == 1'b0) begin
            cycle = cycle + 1;

            if (UUT.IR == 32'h00000073) begin
                $display("\n=================================");
                if (X3 == 32'd1) begin
                    $display(" [TEST PASSED]");
                    $display(" Total Cycle: %0d", cycle);
                end else begin
                    $display(" [TEST FAILED]");
                    $display(" Failed Sub-test ID: %0d", (X3 >> 1));
                    $display(" Raw gp(x3) Value  : %0d", X3);
                    $display(" Last PC           : 0x%08h", PC_debug);
                    $display(" Total Cycle       : %0d", cycle);
                end
                $display("=================================\n");
                $finish;
            end

            if (cycle >= 15000) begin
                $display("\n=================================");
                $display(" [TIMEOUT] (15000 CYCLES)");
                $display(" Last PC: 0x%08h | gp(x3): %0d", PC_debug, X3);
                $display("=================================\n");
                $finish;
            end
        end
    end

endmodule