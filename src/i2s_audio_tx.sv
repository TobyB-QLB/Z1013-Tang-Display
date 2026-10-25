// I2S master for MAX98357A: 48 kHz, two 32-bit slots, 16-bit signed mono.
// Data changes on BCLK falling edges and is sampled on rising edges.
// LRCK changes one bit before each MSB, as required by I2S (not left-justified).
module i2s_audio_tx #(
    parameter integer CLOCK_HZ = 33000000,
    parameter integer SAMPLE_HZ = 48000
)(
    input wire clk, reset_n,
    input wire signed [15:0] sample,
    output reg bclk, lrck, din,
    output wire enable
);
    localparam integer HALF_BIT_HZ = SAMPLE_HZ * 128;
    reg [26:0] phase;
    reg [5:0] bit_index;
    reg [15:0] frame_sample;
    wire [5:0] next_bit = bit_index + 6'd1;
    assign enable = reset_n;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            phase <= 0;
            bclk <= 0;
            lrck <= 0;
            din <= 0;
            bit_index <= 63;
            frame_sample <= 0;
        end else if (phase >= CLOCK_HZ - HALF_BIT_HZ) begin
            phase <= phase + HALF_BIT_HZ - CLOCK_HZ;
            bclk <= ~bclk;
            if (bclk) begin
                bit_index <= next_bit;
                // The last bit of the preceding slot announces the next channel.
                lrck <= (next_bit >= 31 && next_bit < 63);
                if (next_bit == 0) begin
                    frame_sample <= sample;
                    din <= sample[15];
                end else if (next_bit < 16) begin
                    din <= frame_sample[15-next_bit];
                end else if (next_bit >= 32 && next_bit < 48) begin
                    din <= frame_sample[47-next_bit];
                end else begin
                    din <= 0;
                end
            end
        end else begin
            phase <= phase + HALF_BIT_HZ;
        end
    end
endmodule
