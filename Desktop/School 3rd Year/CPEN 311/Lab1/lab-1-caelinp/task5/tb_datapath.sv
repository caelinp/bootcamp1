`define reset_ON   0
`define reset_OFF  1
`define clock_HIGH 0
`define clock_LOW  1

module tb_datapath();
  // internal signals for all inputs
  logic slow_clock, fast_clock, resetb, load_pcard1, load_pcard2, load_pcard3, load_dcard1,
        load_dcard2, load_dcard3;
  // internal signals for all outputs, and some extra internal signals for testing purposes
  logic [3:0] pcard3_out, pscore_out, dscore_out, p1_prev, p2_prev, p3_prev, d1_prev, d2_prev, d3_prev,
              pscore_prev, dscore_prev;
  logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
  // instantiate module
  datapath dut(.*);     
 
  // No need to have continuous slow_clock, we can simulate clock key presses
  // But we can run continuous fast_clock, to help us generate random cards  
  initial begin
    fast_clock = 0;
    forever #1 fast_clock = ~fast_clock;				
  end
  // test cases below
  initial begin
/* 
 * This tests all inputs being low, and ensures all outputs are low (despite some undefined
 * internal signals)
 */
    resetb = `reset_ON;
    #5;		
    slow_clock = `clock_LOW; // initialize clock key unpressed
    // initialize load signals to low and reset signal to low
    // (active-low, so initialize to 1)
    load_pcard1 = 0;
    load_pcard2 = 0;
    load_pcard3 = 0;
    load_dcard1 = 0; 
    load_dcard2 = 0;
    load_dcard3 = 0;
    resetb = `reset_OFF;   
    #5;
    // All outputs except pcard3_out should be defined and equal to 0, because player and dealer do not have
    // any cards or scores. Internal signals for card slots and pcard3_out should be 0
    assert({pscore_out, dscore_out, ~HEX5, ~HEX4, ~HEX3, ~HEX2, ~HEX1, ~HEX0, dut.PCard1,
            dut.PCard2, dut.PCard3, dut.DCard1, dut.DCard2, dut.DCard3, pcard3_out} == 0);   
    
    // update all prev signals to compare in future tests
    p1_prev = dut.PCard1;
    p2_prev = dut.PCard2;
    p3_prev = dut.PCard3;
    d1_prev = dut.DCard1;
    d2_prev = dut.DCard2;
    d3_prev = dut.DCard3;
    pscore_prev = pscore_out;
    dscore_prev = dscore_out;
    #5;
/* 
 * Now test that nothing changed after a clock cycle, because input signals did not change
 */
    // simulate clock cycle
    
    
    slow_clock = `clock_LOW;
    #5;
    slow_clock = `clock_HIGH;
    // outputs and card slot values should not have changed, because no load signals were high
    assert({pscore_out, dscore_out, ~HEX5, ~HEX4, ~HEX3, ~HEX2, ~HEX1, ~HEX0, dut.PCard1,
            dut.PCard2, dut.PCard3, dut.DCard1, dut.DCard2, dut.DCard3, pcard3_out} == 0);  
    #15;
/*
 * Now try to load first card for player, and check that card value, HEX value, and pscore update 
 * after clock cycle, and that no other values do. We do not need to check that pscore is correct
 * in this testbench, as we tested this tb_scorehand, wejust need to ensure it is defined.
 */ 
    load_pcard1 = 1;

    // simulate clock cycle
    slow_clock = `clock_LOW;
    #5;
    slow_clock = `clock_HIGH;
    // dealer score should be 0 and all HEX outputs aside from HEX0 should be off
    assert({dscore_out, ~HEX5, ~HEX4, ~HEX3, ~HEX2, ~HEX1} == 0);
    assert(pscore_out !== 4'bx); // pscore should have a defined value 
    // player's first card slot should be defined
    assert(dut.PCard1 !== 4'bx);
    // other card slots should be 0
    assert({dut.PCard2, dut.PCard3, dut.DCard1, dut.DCard2, dut.DCard3, pcard3_out} == 0);
    // HEX0 should not be blank, as player was dealt a card (correct encoding is tested in tb)
    assert(~HEX0 != 0);
    p1_prev = dut.PCard1;
    p2_prev = dut.PCard2;
    p3_prev = dut.PCard3;
    d1_prev = dut.DCard1;
    d2_prev = dut.DCard2;
    d3_prev = dut.DCard3;
    pscore_prev = pscore_out;
    dscore_prev = dscore_out;
    #37;

/*
 * The following tests will be similar to the previous test, and check that all card slots
 * update given the corresponding load signals, and that all HEX displays update accordingly
 */
    // enable dealer getting first card and disable player getting first card
    load_dcard1 = 1;
    load_pcard1 = 0;

    // simulate clock cycle
    slow_clock = `clock_LOW;
    #5;
    slow_clock = `clock_HIGH;

    // dscore and value of dealer's first card slot should be defined
    assert(dscore_out !== 4'bx);
    assert(dut.DCard1 !== 4'bx);
    // pcard3_out, and the rest of the card slots should still be 0
    assert({pcard3_out, dut.PCard2, dut.PCard3, dut.DCard2, dut.DCard3} == 0);
    // HEX(1-2 and 4-5) should be all be blank
    assert({~HEX1, ~HEX2, ~HEX4, ~HEX5} == 0);
    // HEX0 and HEX3 should not be blank
    assert(~HEX0 != 0);
    assert(~HEX3 != 0);
    // ensure player's score did not change
    assert(pscore_out == pscore_prev);
    // ensure player's first card slot value did not change in this clock cycle
    assert(dut.PCard1 == p1_prev)
    p1_prev = dut.PCard1;
    p2_prev = dut.PCard2;
    p3_prev = dut.PCard3;
    d1_prev = dut.DCard1;
    d2_prev = dut.DCard2;
    d3_prev = dut.DCard3;
    pscore_prev = pscore_out;
    dscore_prev = dscore_out;
    #6;
    
    // enable player to receive second card, disable dealer to get card
    load_dcard1 = 0;
    load_pcard2 = 1;

    // simulate clock cycle
    slow_clock = `clock_LOW;
    #5;
    slow_clock = `clock_HIGH;
    // ensure dscore, player's first card, and dealer's first card did not change
    assert(dscore_out == dscore_prev);
    assert(dut.PCard1 == p1_prev);
    assert(dut.DCard1 == d1_prev);

    // player's second card slot and new pscore should be defined
    assert(dut.PCard2 !== 4'bx);
    assert(pscore_out !== 4'bx);

    // HEX(0, 1 and 3) should be non-blank and the rest should be blank
    assert(~HEX0 != 0);
    assert(~HEX1 != 0);
    assert(~HEX3 != 0);
    assert({~HEX2, ~HEX4, ~HEX5} == 0); 

    // remaining card slots and pcard3_out should be 0
    assert({dut.PCard3, dut.DCard2, dut.DCard3, pcard3_out} == 0);   

    p1_prev = dut.PCard1;
    p2_prev = dut.PCard2;
    p3_prev = dut.PCard3;
    d1_prev = dut.DCard1;
    d2_prev = dut.DCard2;
    d3_prev = dut.DCard3;
    pscore_prev = pscore_out;
    dscore_prev = dscore_out;
    #13;

    // now enable dealer getting second card and disable player getting card
    load_dcard2 = 1;
    load_pcard2 = 0;

    // simulate clock cycle
    slow_clock = `clock_LOW;
    #5;
    slow_clock = `clock_HIGH;

    // pscore, and values of player's two cards and dealer's first cards should stay same
    assert(pscore_out == pscore_prev);
    assert(dut.PCard1 == p1_prev);
    assert(dut.PCard2 == p2_prev);
    assert(dut.DCard1 == d1_prev);

    // ensure that dealer's second card slot and new dscore are defined
    assert(dut.DCard2 !== 4'bx);
    assert(dscore_out !== 4'bx);

    // HEX(0, 1, 3, 4) should be non-blank and the rest should be blank
    assert(~HEX0 != 0);
    assert(~HEX1 != 0);
    assert(~HEX3 != 0);
    assert(~HEX4 != 0);
    assert({~HEX2, ~HEX5} == 0);

    // ensure that remaining card slots and pcard3_out signal are 0
    assert({dut.PCard3, dut.DCard3, pcard3_out} == 0);
    
    p1_prev = dut.PCard1;
    p2_prev = dut.PCard2;
    p3_prev = dut.PCard3;
    d1_prev = dut.DCard1;
    d2_prev = dut.DCard2;
    d3_prev = dut.DCard3;
    pscore_prev = pscore_out;
    dscore_prev = dscore_out;
    #27;

    // enable player getting third card, disable dealer getting the card 
    load_pcard3 = 1;
    load_dcard2 = 0;

    // simulate clock cycle
    slow_clock = `clock_LOW;
    #5;
    slow_clock = `clock_HIGH;

    // dscore, values of all hands with cards should not have changed
    assert(dscore_out == dscore_prev);
    assert(dut.PCard1 == p1_prev);
    assert(dut.PCard2 == p2_prev);
    assert(dut.DCard1 == d1_prev);
    assert(dut.DCard2 == d2_prev);

    // ensure that new pscore and player's third card, slot now defined
    assert(pscore_out !== 4'bx);
    assert(dut.PCard3 !== 4'bx);
    // pcard3 signal should equal third card slot face value
    assert(pcard3_out == dut.PCard3);

    // ensure that all HEX non-blank except HEX5
    assert(~HEX0 != 0);
    assert(~HEX1 != 0);
    assert(~HEX2 != 0);
    assert(~HEX3 != 0);
    assert(~HEX4 != 0);
    assert(~HEX5 == 7'b0);

    // ensure that dealer's third card slot still 0
    assert(dut.DCard3 == 0);

    p1_prev = dut.PCard1;
    p2_prev = dut.PCard2;
    p3_prev = dut.PCard3;
    d1_prev = dut.DCard1;
    d2_prev = dut.DCard2;
    d3_prev = dut.DCard3;
    pscore_prev = pscore_out;
    dscore_prev = dscore_out;
    #23;

    // enable dealer getting third card, disable player getting card
    load_pcard3 = 0;
    load_dcard3 = 1;
    
    // simulate clock cycle
    slow_clock = `clock_LOW;
    #5;
    slow_clock = `clock_HIGH;

    // pscore, all player cards, two dealer cards, and pcard3 signal should not have changed
    assert(pscore_out == pscore_prev);
    assert(dut.PCard1 == p1_prev);
    assert(dut.PCard2 == p2_prev);
    assert(dut.PCard3 == p3_prev);
    assert(dut.DCard1 == d1_prev);
    assert(dut.DCard2 == d2_prev);
    assert(pcard3_out == dut.PCard3);

    // dscore, dealer's third card slot should be defined now
    assert(dscore_out !== 4'bx);
    assert(dut.DCard3 !== 4'bx);

    // pcard3 should still keep value of player's third card
    assert (pcard3_out == dut.PCard3);

    // all HEX displays should be non-blank
    assert(~HEX0 != 0);
    assert(~HEX1 != 0);
    assert(~HEX2 != 0);
    assert(~HEX3 != 0);
    assert(~HEX4 != 0);
    assert(~HEX5 != 0);

    // no output or card signals should be undefined

/*
 * Testing reset button. A press of the reset button should
 * set card slot values, pscore, dscore, and pcard3 signals to 0
 * (not undefined), and all HEX displays to blank. This should
 * not depend on a clock cycle occurring
 */
    // do not load any registers
    load_pcard1 = 0;
    load_pcard2 = 0;
    load_pcard3 = 0;
    load_dcard1 = 0; 
    load_dcard2 = 0;
    load_dcard3 = 0;
    resetb = `reset_ON;
    #5;
    resetb = `reset_OFF;
    // all score and card signals should be low, HEX displays all blank
    assert({pscore_out, dscore_out, ~HEX5, ~HEX4, ~HEX3, ~HEX2, ~HEX1, ~HEX0,
            dut.PCard1, dut.PCard2, dut.PCard3, dut.DCard1, dut.DCard2, 
            dut.DCard3, pcard3_out} == 0);
  end				
endmodule


