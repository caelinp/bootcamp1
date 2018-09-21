`define reset_ON  0
`define reset_OFF 1
`define Start  3'b000
`define DealP1 3'b001
`define DealD1 3'b010
`define DealP2 3'b011
`define DealD2 3'b100
`define DealP3 3'b101
`define DealD3 3'b110
`define Over   3'b111

module tb_statemachine();
  logic slow_clock, resetb, load_pcard1, load_pcard2,
        load_pcard3, load_dcard1, load_dcard2, load_dcard3,
        player_win_light, dealer_win_light;
  logic [3:0] dscore, pscore, pcard3;
  // instantiate module for testing   
  statemachine dut(.*);
  // Start clock
  initial begin
    slow_clock = 0;
    forever #5 slow_clock = ~slow_clock;				
  end
// Test cases below  
  initial begin
/* 
 * It should begin in undefined state, so we must press reset to move into Start state
 */
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0 in this stage, except load_pcard1 	
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
/* 
 * Now we should be in state DealP1, in which a card has been dealt to the player
 * and we can give them a non-zero pscore. load_pcard1 should be high, and all
 * other load signals should be low. Win signals should also be low.
 */
    // player was dealt a 4
    pscore = 'd4;
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
/*
 * Now we should be in state DealD1, in which a card has been dealt to the player
 * and dealer, and we can give both a non-zero dscore. load_pcard2 should be high,
 * and all other load signals should be low. Win signals should also be low.
 */
    // dealer dealt a 5 
    dscore = 'd5;
   // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_dcard1, load_pcard3, load_pcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
/*
 * Now we should be in state DealP2, in which a second card is dealt to the player.
 * We can update the pscore and leave the dscore as it was from last turn. load_dcard2 
 * should be high and all other load signals should be low. Win signals should also be low.
 */
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
    // load_dcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
/*
 * Now we should be in state DealD2, in which a second card is dealt to the dealer.
 * We can update the dscore and leave the dscore as it was from last turn. All load signals 
 * should be should be low. Win signals should also be low.
 */
    // imagine dealer was dealt am Ace, then score would be (5+1)%10 = 6
    dscore = 'd6;
    // All outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
	    load_dcard2, load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
/*
 * We will first test a situation in which all states are reached. dscore is 6 and pscore is 3
 * so the player will receive another card. load_pcard3 should be high and all other load signals
 * and the win signals should be low.
 */
    // imagine player was dealt a 7, then pscore would be (4+9+7)%10 = 0
    pcard3 = 7;
    pscore = 0;
    // All other outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;

/*
 * The dealer will get another card because their score is 6, and the player's third card was a 7.
 * load_dcard3 should be high and all other load signals and win signals should be low.
 */
    // imagine dealer was dealt a 9, then dscore would be (5+1+8)%10 = 4
    dscore = 'd4;
    // All outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
	    load_dcard2, load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealD3 state
    assert(dut.state == `DealD3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
/* 
 * Now game should move into Over state, and the winner should be known (dealer).
 * All load signals should be low, player_win_light should be low and dealer_win_light
 * should be high.
 */
    // dealer win light should be high
    assert(dealer_win_light == 1);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);










/*
 * Now we test a scenario in which the player's score from their
 * first two cards was 0-5, and the banker's score from the first
 * two cards was 7. The player should get a third card, the banker 
 * should not, and the game should be over. We can copy the beginning
 * of the previous test for this situation, up until the player gets 
 * their third card.
 */   
    #10;
    // press reset button (to bring us back to start)
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
    // load_dcard1 should be high and all other outputs low
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
    // load_dcard1 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
    // load_pcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt an Ace, then score would be (5+1)%10 = 6
    dscore = 'd6;
    // all  outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard2, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine player was dealt a 7, then pscore would be (4+9+7)%10 = 0
    pcard3 = 'd7;
    dscore = 'd7; // dealer score is 7, they should not get a third card
    pscore = 0;
    //  outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // dealer light should be high and player low
    assert({dealer_win_light, player_win_light} == 2'b10);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);









/*
 * Now test banker having score of 6 from first two cards, and player 
 * having a King for their third card. Dealer should not receive a third
 * and game should move to over after DealP3. 
 */ 
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_dcard1, load_pcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt an Ace, then score would be (5+1)%10 = 6
    dscore = 'd6;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, load_dcard2, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine player was dealt a 7, then pscore would be (4+9+0)%10 = 3
    pcard3 = 'd13;
    dscore = 'd6; // dealer score is 6, they should not get a third card
    pscore = 'd3;
     
    // load_pcard3 should be high and all other outputs low
    assert({load_pcard1, load_pcard2, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light, load_pcard3} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // dealer light should be high and player light low
    assert({dealer_win_light, player_win_light} == 2'b10);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);
  







/*
 * Now test banker's score from first two cards being 5, and player's last
 * card being 4. Banker should get a third card then game should be over.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt King, then score would be (5)%10 = 5
    dscore = 'd5;

    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine player was dealt a 4, then pscore would be (4+9+4)%10 = 3
    pcard3 = 'd4;
    pscore = 'd3;
    assert({load_pcard1, load_pcard2, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light, load_pcard3} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine dealer was dealt a 9, then dscore would be (5+1+9)%10 = 5
    dscore = 'd5;
     
    // load_dcard3 should be high and all other outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard2, player_win_light, dealer_win_light, load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in DealD3 state
    assert(dut.state == `DealD3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer win light should be high
    assert(dealer_win_light == 1);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    resetb = `reset_ON;
    #10;
    resetb = `reset_OFF;
    // we should be back in the start state, so that check all outputs are low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});  
    assert(dut.state == `Start);
    $display("%b", dut.state);









/*
 * Now test dealer's score from first two cards being 5 and pcard3 being 1.
 * Dealer should not get third card.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
     
    // load_dcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt a 10, then score would be (5)%10 = 5
    dscore = 'd5;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine player was dealt an 8, then pscore would be (4+9+8)%10 = 1
    pcard3 = 'd8;
    dscore = 'd5; // dealer score is 5, they should not get a third card
    pscore = 'd1;
    // all outputs low
    assert({load_pcard1, load_pcard2, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light, load_pcard3} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // dealer light should be high and player light low
    assert({dealer_win_light, player_win_light} == 2'b10);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);










/*
 * Now test banker's score from first two cards being 4, and player's last
 * card being 4. Banker should get a third card then game should be over.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
     
    // load_dcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard3,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt a 9, then score would be (5+9)%10 = 4
    dscore = 'd4;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine player was dealt a 4, then pscore would be (4+9+4)%10 = 3
    pcard3 = 'd4;
    pscore = 'd3;
    // all outputs low
    assert({load_pcard1, load_pcard2, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light, load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine dealer was dealt an 8, then dscore would be (5+9+8)%10 = 2
    dscore = 'd2;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard2, player_win_light, dealer_win_light, load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in DealD3 state
    assert(dut.state == `DealD3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // player win light should be high
    assert(player_win_light == 1);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    resetb = `reset_ON;
    #10;
    resetb = `reset_OFF;
    // we should be back in the start state, so that check all outputs are low except load_pcard1
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});  
    assert(dut.state == `Start);
    $display("%b", dut.state);

















/*
 * Now test dealer's score from first two cards being 4 and pcard3 being 8.
 * Dealer should not get third card.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt a 9, then score would be (5+1)%10 = 6
    dscore = 'd6;
     
    // load_dcard2 should be high and all other outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine player was dealt an 8, then pscore would be (4+9+8)%10 = 1
    pcard3 = 'd8;
    dscore = 'd4; // dealer score is 4, they should not get a third card
    pscore = 'd1;
    // all outputs low
    assert({load_pcard1, load_pcard2, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light, load_pcard3} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // dealer light should be high and player light low
    assert({dealer_win_light, player_win_light} == 2'b10);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);










/*
 * Now test banker's score from first two cards being 3, and player's last
 * card being 4. Banker should get a third card then game should be over.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
     
    // load_dcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt an 8, then score would be (5+8)%10 = 3
    dscore = 'd3;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine player was dealt a 4, then pscore would be (4+9+4)%10 = 3
    pcard3 = 'd4;
    pscore = 'd3;
    // all outputs low
    assert({load_pcard1, load_pcard2, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light, load_pcard3} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine dealer was dealt an 8, then dscore would be (5+8+8)%10 = 1
    dscore = 'd1;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard2, player_win_light, dealer_win_light, load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in DealD3 state
    assert(dut.state == `DealD3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // player win light should be high
    assert(player_win_light == 1);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    resetb = `reset_ON;
    #10;
    resetb = `reset_OFF;
    // we should be back in the start state, so that check all outputs are low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});  
    assert(dut.state == `Start);
    $display("%b", dut.state);

















/*
 * Now test dealer's score from first two cards being 3 and pcard3 being 8.
 * Dealer should not get third card.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt a 3, then score would be (5+8)%10 = 3
    dscore = 'd3;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine player was dealt an 8, then pscore would be (4+9+8)%10 = 1
    pcard3 = 'd8;
    dscore = 'd3; // dealer score is 3, they should not get a third card
    pscore = 'd1;
    // all outputs low
    assert({load_pcard1, load_pcard2, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light, load_pcard3} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // dealer light should be high and player light low
    assert({dealer_win_light, player_win_light} == 2'b10);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);












/*
 * Now test banker's score from first two cards being 2. They will get
 * a third card in any case, then game over.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light, load_dcard1} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
     
    // load_dcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light, load_pcard2} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt an 7, then score would be (5+7)%10 = 2
    dscore = 'd2;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine player was dealt a 4, then pscore would be (4+9+4)%10 = 3
    pcard3 = 'd4;
    pscore = 'd3;
    // outputs low
    assert({load_pcard1, load_pcard2, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light, load_pcard3} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealP3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine dealer was dealt an 8, then dscore would be (5+7+8)%10 = 0
    dscore = 'd0;
     
    // outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard2, player_win_light, dealer_win_light, load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in DealD3 state
    assert(dut.state == `DealD3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // player win light should be high
    assert(player_win_light == 1);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    resetb = `reset_ON;
    #10;
    resetb = `reset_OFF;
    // we should be back in the start state, so that check all outputs are low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});  
    assert(dut.state == `Start);
    $display("%b", dut.state);











/*
 * Now test player's score from first two cards being 9. Game should be over
 * after DealD2.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+5)%10 = 9
    pscore = 'd9;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt a 2, then score would be (5+2)%10 = 7
    dscore = 'd7;
     
    // outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // dealer light should be low and player light high
    assert({dealer_win_light, player_win_light} == 2'b01);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);









/*
 * Now test dealer's score from first two cards being 8. Game should be over
 * after DealD2.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 9, then score would be (4+9)%10 = 3
    pscore = 'd3;
     
    // load_dcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt a 3, then score would be (5+3)%10 = 8
    dscore = 'd8;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // dealer light should be high and player light low
    assert({dealer_win_light, player_win_light} == 2'b10);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);













/*
 * Now test player having score of 6 after two cards, and dealer has score
 * 4. Player should not get a third card and dealer should.
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 2, then score would be (4+2)%10 = 6
    pscore = 'd6;
     
    // load_dcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt a 10, then score would be (5)%10 = 5
    dscore = 'd5;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // imagine dealer was dealt an 8, then dscore would be (4+9+8)%10 = 1
    pcard3 = 'd0;
    dscore = 'd1;
    pscore = 'd6;
     
    // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealP3 state
    assert(dut.state == `DealD3);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer light should be low and player light high
    assert({dealer_win_light, player_win_light} == 2'b01);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);
  








/*
 * Now test player's score from first two cards being 7 and dealer's being
 * 7. Neither should get a third card
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // imagine player was dealt a 3, then score would be (4+3)%10 = 7
    pscore = 'd7;

    // load_dcard2 should be high and all other outputs low
    assert(load_dcard2 == 1);
    assert({load_pcard1, load_pcard3, load_dcard1, load_pcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP2 state
    assert(dut.state == `DealP2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);     
    #10;
    // imagine dealer was dealt a 3, then score would be (5+2)%10 = 7
    dscore = 'd7;
     
     // all outputs low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard3, player_win_light, dealer_win_light, load_dcard2} == 0);
    // check internal state of statemachine, ensure it is in DealD2 state
    assert(dut.state == `DealD2);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #20;
    // dealer light and player light should be high (tie)
    assert({dealer_win_light, player_win_light} == 2'b11);
    // all other outputs should be low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3} == 0);
    // check internal state of statemachine, ensure it is in Over state
    assert(dut.state == `Over);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);






/*
 * Now test reset in a state other than over
 */
    #10;
    // press reset button
    resetb = `reset_ON;
    // scores and player's 3rd card should be 0
    {pcard3, dscore, pscore} = 0;
    #10;
    // unpress reset button
    resetb = `reset_OFF;
     
    // assert all output signals should be 0, except for load_pcard1 because state DealP1 should follow
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    assert(dut.state == `Start);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});   
    $display("%b", dut.state); 
    #10;
    // player was dealt a 4
    pscore = 'd4;
     
    // load_dcard1 should be high and all other outputs low
    assert(load_dcard1 == 1);
    assert({load_pcard2, load_pcard3, load_pcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealP1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state); 
    #10;
    // dealer dealt a 5 
    dscore = 'd5;
     
    // load_pcard2 should be high and all other outputs low
    assert(load_pcard2 == 1);
    assert({load_pcard1, load_dcard1, load_pcard3, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light} == 0);
    // check internal state of statemachine, ensure it is in DealP1 state
    assert(dut.state == `DealD1);
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});
    $display("%b", dut.state);    
    #10;
    // now press reset
    resetb = `reset_ON;
    #10;
    resetb = `reset_OFF;
    // we should be back in the start state, so that check all outputs are low
    assert({load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
	    load_dcard3, player_win_light, dealer_win_light} == 8'b10000000);
    // check internal state of statemachine, ensure it is in Start state
    $display("%b", {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2,
        load_dcard3, player_win_light, dealer_win_light});  
    assert(dut.state == `Start);
    $display("%b", dut.state);
  end
endmodule


