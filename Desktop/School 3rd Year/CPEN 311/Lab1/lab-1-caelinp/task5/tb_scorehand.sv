module tb_scorehand();
  // internal signals for inputs and outputs of scorehand module
  logic [3:0] card1, card2, card3, total;
  scorehand dut(.*); // instantiating device under test
// test cases below  
  initial begin
/*
 * Test normal inputs 5, 6, 8. Total should be correct score calculated for all inputs.
 */ 
    card1 = 'd5;
    card2 = 'd8;
    card3 = 'd6; // 6, value 6
    #5; 
    assert(total == 'd9); // total should be (5+8+6)%10=9
    $display("inputs: %d, %d, %d", card1, card2, card3);
    $display("total: %d", total);
/*
 * Test card values of 0 (starting value for slots that have not been dealt to) and
 * ensure correct behavior (total should be 0)
 */
    card1 = 'd0; // represents king (value 0)
    card2 = 'd0; // 10, value 0
    card3 = 'd0; // undefined
    #5;
    assert(total == 0) // total should be (0+0+0)%10=0
    $display("inputs: %d, %d, %d", card1, card2, card3);
    $display("total: %d", total);

/*
 * Test a Jack, a Queen, and a 4. Total should be 4
 */
    card1 = 'd11; // represents Jack (value 0)
    card2 = 'd4; // 4, value 4
    card3 = 'd12; // Queen (0)
    #5;
    assert(total == 'd4); // total should be (0+4+0)%10=4
    $display("inputs: %d, %d, %d", card1, card2, card3);
    $display("total: %d", total);

/*
 * Test three different inputs, including a King, which should be valued as 0
 */
    card1 = 'd13; // represents king (value 0)
    card2 = 'd7; // 7, value 7
    card3 = 'd5; // 5, value 5
    #5;
    assert(total == 'd2); // total should be (0+7+5)%10=2
    $display("inputs: %d, %d, %d", card1, card2, card3);
    $display("total: %d", total);

/*
 * We decided that values such as 14 and 15 as inputs would be 
 * valid for this module to process, despite the fact that the 
 * datapath should never give us these values for cards. These 
 * imaginary cards should be given values of 0, and the total 
 * should be calculated as normal under that assumption. 
 */
    card1 = 'd14; // imaginary card (value 0)
    card2 = 'd15; // imaginary card (value 0)
    card3 = 'd5; // 5, value 5
    #5;
    assert(total == 'd5); // total should be (0+0+5)%10=5;
    $display("inputs: %d, %d, %d", card1, card2, card3);
    $display("total: %d", total);

/*
 * This will test a situation with inputs that, when summed in the 
 * intermediate step of the operation (a+b+c)%10=total, would overflow
 * a 4-bit signal. The total value of any operation would not overflow
 * the 4-bit signal because of the %10, so ensure that total signal is 
 * correct.
 */
    card1 = 'd9; // 9, value 9
    card2 = 'd8; // 8, value 8
    card3 = 'd9; // 9, value 9
    #5;
    assert(total == 'd6); // total should be (9+8+9)%10
    $display("inputs: %d, %d, %d", card1, card2, card3);
    $display("total: %d", total);

/* 
 * Last test of another possible combination of inputs.
 */    
    card1 = 'd9; // 9, value 9
    card2 = 'd0; // 0, value 0
    card3 = 'd9; // 9, value 9
    #5;
    assert(total == 'd8); // total should be (9+0+9)%10=8
    $display("inputs: %d, %d, %d", card1, card2, card3);
    $display("total: %d", total);
  end						
endmodule

