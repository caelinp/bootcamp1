/* 
 * This testbench is not automated, and simply simulates arbitrary-length clock
 * cycles, and has arbitrary reset button presses. We can track the progress of
 * this simulation on the waveform, checking HEX display outputs, LEDR outputs
 * and datapath internal card registers to ensure that it functions as described
 * by the instructions of the game, and that reset does in fact reset our values.
 * I will not test every scenario in the game by manipulating the clock cycles to
 * get certain values to trigger all the different modes, because all game scenarios
 * were tested in the statemachine testbench.  
 */
module tb_lab1();
  // internal signals for inputs
  logic CLOCK_50;
  logic [3:0] KEY;
  // internal signals for outputs
  logic [9:0] LEDR;
  logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
  
  // instantiate module
  lab1 dut(.*);

  // start continuous fast clock
  initial begin
    CLOCK_50 = 0;
    forever #1 CLOCK_50 = ~CLOCK_50;				
  end		
  initial begin
    // clock key starts unpressed
    KEY[0] = 1;
    // reset starts unpressed
    KEY[3] = 1;
    #5;
    // reset pressedz
    KEY[3] = 0;
    #4;
    // reset unpressed
    KEY[3] = 1;
    #8;
    KEY[0] = 0;
    #7;
    KEY[0] = 1;
    #24;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    KEY[0] = 0;
    #15;
    KEY[0] = 1;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    KEY[0] = 0;
    #15;
    KEY[0] = 1;
    #13;
    // reset pressed
    KEY[3] = 0;
    #4;
    KEY[0] = 0;
    #7;
    // reset unpressed
    KEY[3] = 1;
    #4;
    KEY[0] = 0;
    #24;
    KEY[0] = 1;
    #16;
    KEY[0] = 1;
    #24;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    KEY[0] = 0;
    #15;
    KEY[0] = 1;
    #13;
    // reset pressed
    KEY[3] = 0;
    #4;
    KEY[0] = 0;
    #7;
    // reset unpressed
    KEY[3] = 1;
    #4;
    KEY[0] = 0;
    #24;
    KEY[0] = 1;
    #16;
    KEY[0] = 1;
    #24;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #13
    KEY[0] = 0;
    #24;
    KEY[0] = 1;
    #16;
    KEY[0] = 1;
    #24;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    #13;
    // reset pressed
    KEY[3] = 0;
    #4;
    KEY[0] = 0;
    #7;
    // reset unpressed
    KEY[3] = 1;
    #4;
    KEY[0] = 0;
    #24;
    KEY[0] = 1;
    #16;
    KEY[0] = 1;
    #24;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;KEY[0] = 1;
    #13;
    // reset pressed
    KEY[3] = 0;
    #4;
    KEY[0] = 0;
    #7;
    // reset unpressed
    KEY[3] = 1;
    #4;
    KEY[0] = 0;
    #24;
    KEY[0] = 1;
    #16;
    KEY[0] = 1;
    #24;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    KEY[0] = 0;
    #15;
    KEY[0] = 1;
    #13;
    // reset pressed
    KEY[3] = 0;
    #4;
    KEY[0] = 0;
    #7;
    // reset unpressed
    KEY[3] = 1;
    #4;
    KEY[0] = 0;
    #24;
    KEY[0] = 1;
    #16;
    KEY[0] = 1;
    #24;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #13
    KEY[0] = 0;
    #24;
    KEY[0] = 1;
    #16;
    KEY[0] = 1;
    #24;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
    #3;
    KEY[0] = 1;
    #4;
    #13;
    // reset pressed
    KEY[3] = 0;
    #4;
    KEY[0] = 0;
    #7;
    // reset unpressed
    KEY[3] = 1;
    #4;
    KEY[0] = 0;
    #24;
    KEY[0] = 1;
    #16;
    KEY[0] = 1;
    #24;
    KEY[0] = 0;
    #16;
    KEY[0] = 1;
    #19;
    KEY[0] = 0;
    #22;
    KEY[0] = 1;
    #12;
    KEY[0] = 0;
  end
endmodule

