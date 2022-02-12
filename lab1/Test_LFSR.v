module test_LFSR;

reg clk;
reg rst;
wire [2:0] prn;

LFSR_PRNG DUT (
    .clk    (clk),
    .rst    (rst),
    .prn    (prn)
);

parameter full_period=20000;

// make the clock
always #(full_period / 2) clk = ~clk;

initial begin
    // initialize clk to 0, rst to 1
    clk = 0;
    rst = 1;
    #full_period
    // set rst to 0
    rst = 0;
    #(full_period * 65)
    $stop;
end
endmodule