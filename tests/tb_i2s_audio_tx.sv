`timescale 1ns/1ps
module tb_i2s_audio_tx;
 reg clk=0, reset_n=0;
 always #15.1515 clk=~clk;
 reg signed [15:0] sample=16'h936a;
 wire bclk, lrck, din, enable;
 i2s_audio_tx dut(.*);
 integer slot_bit=0, slots=0;
 reg last_lrck=0;
 reg [31:0] shift=0;
 reg [15:0] left_sample;
 time last_rise=0, first_frame=0;
 integer frames=0;
 always @(posedge bclk) begin
  if(reset_n) begin
   if(last_rise!=0 && ($time-last_rise<300 || $time-last_rise>365))
    $fatal(1,"BCLK interval %0t",$time-last_rise);
   last_rise=$time;
   // LRCK transition marks the padding bit immediately before next MSB.
   if(lrck!=last_lrck) begin
    if(slots>1) begin
     if(slot_bit!=31) $fatal(1,"Incorrect slot size %0d",slot_bit);
     if(shift[14:0]!=0) $fatal(1,"Nonzero slot padding");
     if(lrck==1) left_sample=shift[30:15];
     else if(slots>2) begin
      if(shift[30:15]!==left_sample) $fatal(1,"Stereo samples differ");
      if(left_sample!==16'h936a && left_sample!==16'h5ac3)
       $fatal(1,"Corrupt sample %h",left_sample);
      frames=frames+1;
      if(first_frame==0) first_frame=$time;
      if(frames==80) begin
       if(($time-first_frame)<1645000 || ($time-first_frame)>1647000)
        $fatal(1,"Wrong 48-kHz frame rate %t",$time-first_frame);
       $display("PASS: 80 I2S frames, 48 kHz, 32-bit slots, one-bit delay, signed samples, identical channels");
       $finish;
      end
     end
    end
    slots=slots+1;slot_bit=0;shift=0;
   end else if(slots>0) begin
    shift={shift[30:0],din};slot_bit=slot_bit+1;
   end
   last_lrck=lrck;
  end
 end
 initial begin
  #100;reset_n=1;
  #503000;sample=16'h5ac3;
  #3000000;$fatal(1,"Timeout");
 end
endmodule
