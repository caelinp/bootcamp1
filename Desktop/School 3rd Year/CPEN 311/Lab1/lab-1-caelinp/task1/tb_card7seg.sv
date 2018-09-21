module tb_card7seg();
  logic [6:0] HEX0;
  logic [3:0] SW;

  // instantiate module
  card7seg dut(.*);
  
  // actual test cases below
  initial begin
    // testing all switches off
    SW = 4'b0000;
    #5;
    // all display segments should be off
    assert(HEX0 == 7'b1111111);
    #5;
    // testing switch encoding for Ace
    SW = 4'b0001;
    #5;
    // display should show A
    assert(HEX0 == 7'b0001000);
    #5;	
    // testing switch encoding for 2
    SW = 4'b0010;
    #5;
    // display should show 2
    assert(HEX0 == 7'b0100100);
    #5;	
    // testing switch encoding for 3
    SW = 4'b0011;
    #5;
    // display should show 3
    assert(HEX0 == 7'b0110000);
    #5;	
    // testing switch encoding for 4
    SW = 4'b0100;
    #5;
    // display should show 4
    assert(HEX0 == 7'b0011001);
    #5;	
    // testing switch encoding for 5
    SW = 4'b0101;
    #5;
    // display should show 5
    assert(HEX0 == 7'b0010010);
    #5;	
    // testing switch encoding for 6
    SW = 4'b0110;
    #5;
    // display should show 6
    assert(HEX0 == 7'b0000010);
    #5;	
    // testing switch encoding for 7
    SW = 4'b0111;
    #5;
    // display should show 7
    assert(HEX0 == 7'b1111000);
    #5;	
    // testing switch encoding for 8
    SW = 4'b1000;
    #5;
    // display should show 8
    assert(HEX0 == 7'b0000000);
    #5;	
    // testing switch encoding for 9
    SW = 4'b1001;
    #5;
    // display should show 9
    assert(HEX0 == 7'b0010000);
    #5;	
    // testing switch encoding for 10
    SW = 4'b1010;
    #5;
    // display should show 0
    assert(HEX0 == 7'b1000000);
    #5;	
    // testing switch encoding for Jack
    SW = 4'b1011;
    #5;
    // display should show J
    assert(HEX0 == 7'b1100001);
    #5;	
    // testing switch encoding for Queen
    SW = 4'b1100;
    #5;
    // display should show q
    assert(HEX0 == 7'b0011000);
    #5;	
    // testing switch encoding for King
    SW = 4'b1101;
    #5;
    // display should show K
    assert(HEX0 == 7'b0001001);
    #5;
    // testing unused switch configuration 1110
    SW = 4'b1110;
    #5;
    // all display segments should be off
    assert(HEX0 == 7'b1111111);
    #5;
    // testing unused switch configuration 1111
    SW = 4'b1111;
    #5;
    // all display segments should be off
    assert(HEX0 == 7'b1111111);

    SW = 4'bx;
    #5;
    // all display segments should be off
    assert(HEX0 == 7'b1111111);
    $display("If no error messages above, simulation was successful");
  end				
endmodule

