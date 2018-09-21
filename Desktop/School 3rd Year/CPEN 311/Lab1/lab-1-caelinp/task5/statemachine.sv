// constant definitions for 8 states
`define Start  4'b0000
`define DealP1 4'b0001
`define DealD1 4'b0010
`define DealP2 4'b0011
`define DealD2 4'b0100
`define DealP3 4'b0101
`define DealD3 4'b0110
`define Over   4'b0111
`define Score1 4'b1000
`define Score2 4'b1001
module statemachine(input slow_clock, input resetb,
                    input [3:0] dscore, input [3:0] pscore, input [3:0] pcard3,
                    output load_pcard1, output load_pcard2,output load_pcard3,
                    output load_dcard1, output load_dcard2, output load_dcard3,
                    output player_win_light, output dealer_win_light);
  
  logic [3:0] state, next_state; // internal state signals
  logic loadP1, loadP2, loadP3, loadD1, loadD2, loadD3, pWin, dWin; // internal versions of output signals
  
  // continuous assignment of outputs to internal signals
  assign {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, 
          load_dcard3, player_win_light, dealer_win_light} = {loadP1, loadP2, 
          loadP3, loadD1, loadD2, loadD3, pWin, dWin};
  // 3-bit D Flip-Flop synced to slow clock
  vDFF_reset #4 stateDFF(slow_clock, next_state, state, resetb);
  // check reset signal (active low) to determine next stated
  
  // FSM implementation below:
  always @* begin
    case(state)
      /*
       * Starting state, reached when reset button pressed. All load signals but load1 and win 
       * signals low. Player and dealer should have no cards. Next state will be DealP1.
       */
      `Start: {loadP1, loadD1, loadP2, loadD2, loadP3, loadD3, pWin, dWin, next_state} = {8'b10000000, `DealP1};
      /*
       * State for player getting first card. Player should have one card and dealer 
       * should have zero loadD1 should be high and all other outputs low, next state will be DealD1
       */
      `DealP1: {loadP1, loadD1, loadP2, loadD2, loadP3, loadD3, pWin, dWin, next_state} = {8'b01000000, `DealD1};
      
      /* 
       * State for dealer getting first card, loadP2 should be high and all other
       * outputs low. Player and dealer should each have a card. Next state will 
       * be DealP2.
       */
      `DealD1: {loadP1, loadD1, loadP2, loadD2, loadP3, loadD3, pWin, dWin, next_state} = {8'b00100000, `DealP2};

      /*
       * State for player getting second card, loadD2 should be high and all other
       * outputs low. Player should have two cards and dealer should have one. Next
       * state will be DealD2.
       */
      `DealP2: {loadP1, loadD1, loadP2, loadD2, loadP3, loadD3, pWin, dWin, next_state} = {8'b00010000, `DealD2};

      /*
       * State for dealer getting second card, loadD2 should be high and all other
       * outputs low. Player and Dealer should have 2 cards each. The next state 
       * depends on pscore and dscore
       */
      `DealD2: {loadP1, loadD1, loadP2, loadD2, loadP3, loadD3, pWin, dWin, next_state} = {8'b0, `Score1};

      /*
       * State in which we wait for registers to get values based on load signal of
       * previous state.
       */ 
       `Score1: begin
       // if player or dealer has score 8 or 9, game over
         {loadP1, loadD1, loadP2, loadD2, pWin, dWin} = 6'b0;
         if ((dscore > 'd7 && dscore < 'd10) || (pscore > 'd7 && pscore < 'd10))
           {next_state, loadP3, loadD3, pWin, dWin} = {`Over, 4'b0};
         // if player has score 6 or 7, dealer gets 3rd card if dealer's current score
         // less than or equal to 5, else game over
         else if (pscore > 'd5 && pscore < 'd8)
           {next_state, loadP3, loadD3, pWin, dWin} = {(dscore < 'd6 ? {`DealD3, 2'b01} : {`Over, 2'b0}), 2'b0};
         // if player has score that is not 6, 7, 8 or 9, then it is 0-5, and player gets
         // third card
         else
           {next_state, loadP3, loadD3, pWin, dWin} = {`DealP3, 4'b1000};
        end

       /*
        * State for player getting 3rd card. All outputs low. 
        * Player should have three cards and dealer should have two. Next state is another
        * score calculation stage.
        */
       `DealP3: {next_state, loadP1, loadD1, loadP2, loadD2, loadP3, loadD3, pWin, dWin} = {`Score2, 8'b0};
       /*
        * State in which we wait for registers to get values based on load signal of
        * previous state. We use the scores and pcard3 to determine if dealer gets a 3rd
        */ 
       `Score2: begin
        // if dealer's score 7, game over
         {loadP1, loadD1, loadP2, loadD2, loadP3, pWin, dWin} = {7'b0};
         if (dscore == 'd7)
           {next_state, loadD3} = {`Over, 1'b0};
         // if dealer's score 6, can receive a third card if player's third card 6 or 7, else game over
         else if (dscore == 'd6)
           {next_state, loadD3} = (pcard3 > 'd5 && pcard3 < 'd8) ? {`DealD3, 1'b1} : {`Over, 1'b0};
         // if dealer's score 5, can receive a third card if player's third card 4, 5, 6, 7, else game over
         else if (dscore == 'd5)
           {next_state, loadD3} = (pcard3 > 'd3 && pcard3 < 'd8) ? {`DealD3, 1'b1} : {`Over, 1'b0};
         // if dealer's score 4, can receive a third card if player's third card 2, 3, 4, 5, 6, 7, else game over
         else if (dscore == 'd4)
           {next_state, loadD3} = (pcard3 > 'd1 && pcard3 < 'd8) ? {`DealD3, 1'b1} : {`Over, 1'b0};
         // if dealer's score 3, can receive third card if player's third card anything but 8, else game over
         else if (dscore == 'd3)
           {next_state, loadD3} = pcard3 != 'd8 ? {`DealD3, 1'b1} : {`Over, 1'b0};
         // if dealer's score 0, 1, 2, dealer will receive a third.
         else
           {next_state, loadD3} = {`DealD3, 1'b1};
      end
      /*
       * State for dealer getting third card, loadD3 should be high and all other
       * outputs low. Player and Dealer should have three cards each. The next state 
       * will always be Over. 
       */
      `DealD3: {loadP1, loadD1, loadP2, loadD2, loadP3, loadD3, pWin, dWin, next_state} = {8'b0, `Over};
      /*
       * Game over state. load ouputs should all be low, and win signals should 
       * reflect who won the game. Hext state will be same state. This state cannot
       * be left without pressing reset button
       */
      `Over: begin
        {loadP1, loadD1, loadP2, loadD2, loadP3, loadD3, next_state} = {6'b0, `Over};
         // if player score higher, pWin should be high and dWin low
         if (pscore > dscore)
           {pWin, dWin} = 2'b10;
         // if dealer score higher, pWin should be low and dWin high
         else if (pscore < dscore)
           {pWin, dWin} = 2'b01;
         // if dealer score equal to player score, tie, so pWin and dWin high
         else
           {pWin, dWin} = 2'b11;
      end
      /*
       * Default state is undefined, should not be reached after initial upload
       */
      default: {loadP1, loadD1, loadP2, loadD2, loadP3, loadD3, pWin, dWin, next_state} = 12'bx;
    endcase
  end
endmodule

/* 
 * Parameterized D Flip-Flop with active-low reset module for use in FSM
 */
module vDFF_reset(clk, in, out, reset);
  parameter n = 3;
  input logic clk, reset;
  input logic [n-1:0] in;
  output logic [n-1:0] out;
  // 
  always @(posedge clk, negedge reset)
      out = !reset ? 1'b0 : in; // out gets 0 if reset is asserted, else gets in
endmodule

