module datapath(input slow_clock, input fast_clock, input resetb,
                input load_pcard1, input load_pcard2, input load_pcard3,
                input load_dcard1, input load_dcard2, input load_dcard3,
                output [3:0] pcard3_out,
                output [3:0] pscore_out, output [3:0] dscore_out,
                output[6:0] HEX5, output[6:0] HEX4, output[6:0] HEX3,
                output[6:0] HEX2, output[6:0] HEX1, output[6:0] HEX0);
						
  logic [3:0] new_card, PCard1, PCard2, PCard3, DCard1, DCard2, DCard3;
  assign pcard3_out = PCard3;

  // instantiate dealcard module
  dealcard dealcard(fast_clock, resetb, new_card);

  // set up all registers for each card slot
  reg4 p_card1(slow_clock, new_card, PCard1, load_pcard1, resetb);
  reg4 p_card2(slow_clock, new_card, PCard2, load_pcard2, resetb);
  reg4 p_card3(slow_clock, new_card, PCard3, load_pcard3, resetb);
  reg4 d_card1(slow_clock, new_card, DCard1, load_dcard1, resetb);
  reg4 d_card2(slow_clock, new_card, DCard2, load_dcard2, resetb);
  reg4 d_card3(slow_clock, new_card, DCard3, load_dcard3, resetb);
  
  // set up all 7 segment display encoders for all card slots
  card7seg pcard1_HEX(PCard1, HEX0);
  card7seg pcard2_HEX(PCard2, HEX1);
  card7seg pcard3_HEX(PCard3, HEX2);
  card7seg dcard1_HEX(DCard1, HEX3);
  card7seg dcard2_HEX(DCard2, HEX4);
  card7seg dcard3_HEX(DCard3, HEX5);
  
  // set up two scorehand calculators
  scorehand pscore(PCard1, PCard2, PCard3, pscore_out);
  scorehand dscore(DCard1, DCard2, DCard3, dscore_out);
endmodule

/*
 * Parameterized D Flip-Flop with enable and active-low reset module, for use in datapath
 */
module reg4(clk, in, out, load, reset);
  input logic clk, reset, load;
  input logic [3:0] in;
  output logic [3:0] out;
  
  always @(posedge clk, negedge reset) begin
    // at rising edge of clk or falling edge of reset button
    if (!reset) 
      out = 1'b0; // if reset low, out gets 0
    else
      out = load ? in : out; // out will take value of in if load high, else keep value
  end
endmodule

