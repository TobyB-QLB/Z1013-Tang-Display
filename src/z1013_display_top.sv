// Z1013 F3/SD/USB baseline with 480x272 RGB LCD and onboard I2S audio.
module z1013_display_top (
    input wire I_clk, I_rst, I_key,
    input wire I_usb_cs_n, I_usb_sclk, I_usb_mosi,
    output wire O_usb_miso, O_usb_irq_n,
    input wire I_sd_miso,
    output wire [4:0] O_led,
    output wire running, O_sd_clk, O_sd_cs_n, O_sd_mosi,
    output wire LCD_CLK, LCD_DEN, LCD_HS, LCD_VS, LCD_BL,
    output wire [4:0] LCD_R, LCD_B,
    output wire [5:0] LCD_G,
    output wire AUDIO_DIN, AUDIO_BCLK, AUDIO_LRCK, AUDIO_EN
);
    // Preserve the proven 33-MHz CPU, USB macros, SD and TED timing.
    wire serial_clk, sys_clk, sys_lock, lcd_clk, lcd_lock;
    wire clocks_ready = !I_rst && sys_lock && lcd_lock;
    TMDS_rPLL system_pll(.clkin(I_clk), .clkout(serial_clk), .lock(sys_lock));
    CLKDIV system_div(.RESETN(!I_rst && sys_lock), .HCLKIN(serial_clk),
                      .CLKOUT(sys_clk), .CALIB(1'b1));
    defparam system_div.DIV_MODE = "5";
    defparam system_div.GSREN = "false";
    lcd_rpll display_pll(.clkin(I_clk), .clkout(lcd_clk), .lock(lcd_lock));

    // Reset assertion is asynchronous, release is local to each clock domain.
    reg [3:0] sys_reset_pipe, lcd_reset_pipe;
    always @(posedge sys_clk or negedge clocks_ready)
        if (!clocks_ready) sys_reset_pipe <= 0;
        else sys_reset_pipe <= {sys_reset_pipe[2:0],1'b1};
    always @(posedge lcd_clk or negedge clocks_ready)
        if (!clocks_ready) lcd_reset_pipe <= 0;
        else lcd_reset_pipe <= {lcd_reset_pipe[2:0],1'b1};
    wire sys_reset_n = &sys_reset_pipe;
    wire lcd_reset_n = &lcd_reset_pipe;

    wire [7:0] usb_async_event, usb_event;
    wire usb_toggle, usb_valid, usb_miso;
    usb_companion_spi usb_spi_inst (
        .reset(!sys_reset_n), .cs_n(I_usb_cs_n), .sclk(I_usb_sclk),
        .mosi(I_usb_mosi), .miso(usb_miso), .key_event(usb_async_event),
        .event_toggle(usb_toggle), .traffic(), .status_accepted(),
        .config_accepted(), .key_seen(), .key_down());
    assign O_usb_miso = I_usb_cs_n ? 1'bz : usb_miso;
    assign O_usb_irq_n = 1'b1;
    usb_event_cdc usb_cdc_inst (
        .clk(sys_clk), .reset_n(sys_reset_n), .async_event(usb_async_event),
        .async_toggle(usb_toggle), .event_data(usb_event), .event_valid(usb_valid));

    wire [7:0] red, green, blue;
    wire video_de, video_hs, video_vs, sd_activity;
    wire [9:0] ted_frequency_1, ted_frequency_2;
    wire [7:0] ted_control;
    wire ted_reload, cassette_bit, cassette_active;
    wire [4:0] pcm_control;
    testpattern machine (
        .I_pxl_clk(sys_clk), .I_rst_n(sys_reset_n),
        .I_video_clk(lcd_clk), .I_video_rst_n(lcd_reset_n),
        // LCD R3/R4 use the former external PS/2 pins 42/41.
        .I_ps2_clk(1'b1), .I_ps2_data(1'b1),
        .I_usb_event(usb_event), .I_usb_valid(usb_valid), .I_sd_miso(I_sd_miso),
        .I_mode(3'd0), .I_single_r(8'd0), .I_single_g(8'd0), .I_single_b(8'd0),
        // Sipeed color_bar_1: 9 MHz, 520 x 300 total, 57.69 Hz.
        .I_h_total(12'd520), .I_h_sync(12'd4), .I_h_bporch(12'd23), .I_h_res(12'd480),
        .I_v_total(12'd300), .I_v_sync(12'd4), .I_v_bporch(12'd15), .I_v_res(12'd272),
        .I_hs_pol(1'b0), .I_vs_pol(1'b0),
        .O_de(video_de), .O_hs(video_hs), .O_vs(video_vs),
        .O_data_r(red), .O_data_g(green), .O_data_b(blue),
        .O_sd_clk(O_sd_clk), .O_sd_cs_n(O_sd_cs_n), .O_sd_mosi(O_sd_mosi),
        .O_sd_activity(sd_activity),
        .O_ted_frequency_1(ted_frequency_1), .O_ted_frequency_2(ted_frequency_2),
        .O_ted_control(ted_control), .O_ted_reload(ted_reload), .O_pcm_control(pcm_control),
        .O_cassette_bit(cassette_bit), .O_cassette_active(cassette_active));

    // Launch on internal rising edge; panel samples on the opposite edge.
    assign LCD_CLK = ~lcd_clk;
    assign LCD_DEN = lcd_reset_n && video_de;
    assign LCD_HS = video_hs;
    assign LCD_VS = video_vs;
    assign LCD_R = video_de ? red[7:3] : 5'd0;
    assign LCD_G = video_de ? green[7:2] : 6'd0;
    assign LCD_B = video_de ? blue[7:3] : 5'd0;
    assign LCD_BL = lcd_reset_n;
    assign O_led = {4'b1111, ~sd_activity};
    assign running = 1'b1;

    wire signed [15:0] audio_sample;
    ted_sound_core sound (
        .clk(sys_clk), .reset_n(sys_reset_n),
        .frequency_1(ted_frequency_1), .frequency_2(ted_frequency_2),
        .voice_1_enable(ted_control[4]), .voice_2_enable(ted_control[5] | ted_control[6]),
        .noise_select(ted_control[6] & ~ted_control[5]), .volume(ted_control[3:0]),
        .sound_reload(ted_reload), .pcm_enable(pcm_control[4]), .pcm_sample(pcm_control[3:0]),
        .cassette_enable(cassette_active), .cassette_bit(cassette_bit), .sample(audio_sample));
    wire signed [15:0] speaker_sample;
    z1013_master_volume speaker_volume (
        .clk(sys_clk), .reset_n(sys_reset_n),
        .event_valid(usb_valid), .event_data(usb_event),
        .sample_in(audio_sample), .sample_out(speaker_sample), .level());
    i2s_audio_tx audio (
        .clk(sys_clk), .reset_n(sys_reset_n), .sample(speaker_sample),
        .bclk(AUDIO_BCLK), .lrck(AUDIO_LRCK), .din(AUDIO_DIN), .enable(AUDIO_EN));
endmodule

// Master gain after TED/PCM/cassette mixing; no Z80 sound register is changed.
// USB HID F4=61, F5=62. One step per key press, repeats suppressed until release.
// Levels 0..8 retain mute..unity gain; level 9 adds 10.15625% amplitude.
// Power-on/reset stays at 2/8 amplitude; signed output saturates safely.
module z1013_master_volume (
    input wire clk, reset_n, event_valid,
    input wire [7:0] event_data,
    input wire signed [15:0] sample_in,
    output reg signed [15:0] sample_out,
    output reg [3:0] level
);
    reg down_held, up_held;
    wire [7:0] gain = (level == 9) ? 8'd141 : {level,4'b0000};
    wire signed [24:0] scaled = sample_in * $signed({1'b0,gain});
    wire signed [17:0] adjusted = scaled >>> 7;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            level <= 4'd2;
            down_held <= 0;
            up_held <= 0;
            sample_out <= 0;
        end else begin
            if (adjusted > 18'sd32767) sample_out <= 16'sh7fff;
            else if (adjusted < -18'sd32768) sample_out <= 16'sh8000;
            else sample_out <= adjusted[15:0];
            if (event_valid) begin
                if (event_data == 8'hff) begin
                    down_held <= 0;
                    up_held <= 0;
                end else begin
                    case (event_data[6:0])
                        7'd61: begin
                            down_held <= !event_data[7];
                            if (!event_data[7] && !down_held && level != 0)
                                level <= level - 1'b1;
                        end
                        7'd62: begin
                            up_held <= !event_data[7];
                            if (!event_data[7] && !up_held && level < 9)
                                level <= level + 1'b1;
                        end
                        default: begin end
                    endcase
                end
            end
        end
    end
endmodule
