`timescale 1ns/1ps
module tb_master_volume;
 reg clk=0,reset_n=0,event_valid=0;
 reg [7:0] event_data=0;
 reg signed [15:0] sample_in=16000;
 wire signed [15:0] sample_out;
 wire [3:0] level;
 always #15 clk=~clk;
 z1013_master_volume dut(.*);
 task send(input [7:0] key);
 begin @(negedge clk);event_valid=1;event_data=key;
 @(negedge clk);event_valid=0;repeat(2) @(negedge clk);end endtask
 task check(input integer expected_level,input integer expected_sample);
 begin
 if(level!==expected_level || sample_out!==expected_sample)
 $fatal(1,"level=%0d sample=%0d; expected %0d %0d",level,sample_out,expected_level,expected_sample);
 end endtask
 integer i;
 initial begin
 #40;reset_n=1;repeat(3) @(negedge clk);check(2,4000);
 send(61);check(1,2000);send(61);check(1,2000);
 send(189);send(61);check(0,0);
 send(189);send(61);check(0,0);
 for(i=0;i<10;i=i+1) begin send(62);send(190);end
 check(9,17625);
 sample_in=32767;repeat(3) @(negedge clk);check(9,32767);
 sample_in=-32768;repeat(3) @(negedge clk);check(9,-32768);
 send(255);send(61);check(8,-32768);
 // F9..F12 and F1..F3 must not alter master gain.
 send(66);send(67);send(68);send(69);send(58);send(59);send(60);check(8,-32768);
 // Disconnect clears held flags without unexpectedly raising gain.
 send(255);check(8,-32768);send(61);check(7,-28672);
 reset_n=0;@(negedge clk);reset_n=1;repeat(3) @(negedge clk);check(2,-8192);
 $display("PASS: F4/F5 gain, saturation, repeat suppression, signed PCM and boost clipping, unplug, reset and unrelated keys");$finish;
 end
endmodule
