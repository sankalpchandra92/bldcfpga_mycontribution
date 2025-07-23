module bldc_fpga(
    input wire clk,
    input wire rst_n,
    input wire h1,
    input wire h2,
    input wire h3,
    output reg pwm,
    output reg gla,
    output reg glb,
    output reg glc,
    output reg gha,
    output reg ghb,
    output reg ghc
);

parameter clk_frequency = 27_000_000;
parameter pwm_freq = 1_000;
parameter pwm_period = clk_frequency / pwm_freq;

reg [$clog2(pwm_period)-1:0] pwm_counter;
reg [7:0] duty_cycle = 120;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_counter <= 0;
        pwm <= 0;
    end else begin
        if (pwm_counter < pwm_period - 1)
            pwm_counter <= pwm_counter + 1;
        else
            pwm_counter <= 0;

        pwm <= (pwm_counter < (pwm_period * duty_cycle / 256)) ? 1'b1 : 1'b0;
    end
end

always @(*) begin
    gla = 0; glb = 0; glc = 0;
    gha = 0; ghb = 0; ghc = 0;

    if (rst_n) begin
        case ({h1, h2, h3})
            3'b001: begin gla = 0; glb = 1; glc = 0; gha = pwm; ghb = 0; ghc = 0; end
            3'b101: begin gla = 0; glb = 0; glc = 1; gha = pwm; ghb = 0; ghc = 0; end
            3'b100: begin gla = 0; glb = 0; glc = 1; gha = 0; ghb = pwm; ghc = 0; end
            3'b110: begin gla = 1; glb = 0; glc = 0; gha = 0; ghb = pwm; ghc = 0; end
            3'b010: begin gla = 1; glb = 0; glc = 0; gha = 0; ghb = 0; ghc = pwm; end
            3'b011: begin gla = 0; glb = 1; glc = 0; gha = 0; ghb = 0; ghc = pwm; end
            default: begin gla = 0; glb = 0; glc = 0; gha = 0; ghb = 0; ghc = 0; end
        endcase
    end
end

endmodule
