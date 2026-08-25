module RISCV_TESTS_TB;
    reg clk;
    reg rst;

    wire [31:0] ALU_debug;
    wire [31:0] RF_debug;
    wire [31:0] PC_debug;
    wire [31:0] MEM_debug;

    integer cycle;

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
        $dumpvars(UUT.RF.registers[3]);

        cycle = 0;
        rst = 1'b1;

        #20 rst = 1'b0;
    end

    always @(posedge clk) begin
        

        if (rst == 1'b0) begin
            cycle <= cycle + 1;
            if (UUT.RF.registers[3] == 32'd1) begin
                $display("\n=================================");
                $display(" [TEST PASSED] ");
                $display(" Cycle Count: %0d", cycle);
                $display("=================================\n");
                $finish;
            end
            if (cycle >= 5000) begin
                $display("\n=================================");
                if (UUT.RF.registers[3] > 32'd1) begin
                    $display(" [TEST FAILED]");
                    $display(" Subtest ID (gp/x3): %0d", UUT.RF.registers[3]);
                end else begin
                    $display(" [TIMEOUT] ");
                end
                $display(" Last PC: 0x%08h", PC_debug);
                $display(" Cycle Count: %0d", cycle);
                $display("=================================\n");
                $finish;
            end
        end
    

    if (cycle >= 5000) begin
                $display("\n[TIMEOUT] (5000 CYCLE)!");
                $display("Son PC: 0x%08h | gp(x3): %0d", PC_debug, UUT.RF.registers[3]);
                $finish;
            end

    end

endmodule