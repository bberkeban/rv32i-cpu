module RF_SVA (
    input clk,
    input rst,

    input [31:0] RF_WRITE_DATA,

    input RF_WRITE_ENABLE,

    input [4:0] RF_READ_SELECT_1,
    input [4:0] RF_READ_SELECT_2,
    
    input [4:0] RF_WRITE_SELECT,

    output [31:0] RF_READ_DATA_1,
    output [31:0] RF_READ_DATA_2
);

    Register_File UUT(
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

    reg start = 1'b0;

    always @(posedge clk) begin
        start <= 1'b1;
    end

    always @(*) begin
        if ($initstate) begin
            assume(rst == 1'b1);
        end
    end

    wire [4:0] ground = 5'b00000;
    always @(*) begin
        if (RF_READ_SELECT_1 == ground) begin
        assert (RF_READ_DATA_1 == 32'b0); 
        end
        if (RF_READ_SELECT_2 == ground) begin
        assert (RF_READ_DATA_2 == 32'b0); 
        end

        if (rst == 1'b1) begin
            assert(RF_READ_DATA_1 == 32'b0);
            assert(RF_READ_DATA_2 == 32'b0);
        end
    end

    
    always @(posedge clk) begin
        if ($past(start)) begin
            if ($past(RF_WRITE_ENABLE) && !$past(rst) && !rst) begin
                if ($past(RF_WRITE_SELECT) != 5'b0) begin
                    if ($past(RF_WRITE_SELECT) == RF_READ_SELECT_1) begin
                        assert(RF_READ_DATA_1 == $past(RF_WRITE_DATA));
                    end
                    if ($past(RF_WRITE_SELECT) == RF_READ_SELECT_2) begin
                        assert(RF_READ_DATA_2 == $past(RF_WRITE_DATA));
                    end
                end
            end

            if (!$past(RF_WRITE_ENABLE) && !$past(rst) && !rst) begin
                if ($past(RF_READ_SELECT_1) == RF_READ_SELECT_1) begin
                    assert(RF_READ_DATA_1 == $past(RF_READ_DATA_1));
                    end
                if ($past(RF_READ_SELECT_2) == RF_READ_SELECT_2) begin
                    assert(RF_READ_DATA_2 == $past(RF_READ_DATA_2));
                    end
            end
        end
    end


    
endmodule