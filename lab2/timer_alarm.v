module timer_alarm(in, rst, clk, state, led);

    input in, rst, clk;
    output reg [2:0]state;
    output [3:0]led;

    parameter Idle = 3'b001, AlarmSet = 3'b010, Alerting = 3'b100;

    reg in_old = 1'b1;
    reg press = 1'b0;
    reg [23:0] clk_div = 24'd0;
	 reg [4:0] counter;
    wire clk_slow;
    wire alarm;


    assign clk_slow = clk_div[23];
    // Edge detector for input
    always @ (posedge clk or posedge (!rst))
        if (!rst) begin
            press <= 1'b0;
            in_old <= 1'b1;
        end
        else begin
            press <= (in == 1'b0) && (in_old == 1'b1)? 1'b1 : 1'b0;
            in_old <= in;
        end

    // State output
    assign led = (state == Alerting)? ({4{clk_slow}} & 4'b1111) : 4'b0000;

    // State transition logic
    always @ (posedge clk)
        if (!rst)
            state <= Idle;
        else begin
            case(state)
                Idle:
                    state <= press? AlarmSet : Idle;
                AlarmSet:
                    state <= alarm? Alerting : AlarmSet;
                Alerting:
                    state <= press? Idle : Alerting;
                default:
                    state <= 3'b000;
            endcase
        end

    // Get a slower clock
    always @ (posedge (!rst) or posedge clk)
        if (!rst)
            clk_div <= 24'd0;
        else
            clk_div <= clk_div + 1;
    
    // Counter at state AlarmSet
    always @ (posedge (clk_slow))
        if (state==AlarmSet)
            counter <= counter + 1;
        else
            counter <= 5'b00000;

    assign alarm = (counter==5'b11111)? 1'b1 : 1'b0;

endmodule