module scorehand(input [3:0] card1, input [3:0] card2, input [3:0] card3, output [3:0] total);
  // internal signals to represent value of card
  logic [3:0] val1, val2, val3;
  // Card values are same as inputs if 0-9, and are 0 for card inputs of 10-13 (10, J, Q, K).
  // We will take inputs as card values directly if they are in range 0-9, and values for inputs 
  // that are out of this ranges will be calculated as 0.
  assign val1 = card1 <= 9 && card1 >= 0 ? card1 : 0;
  assign val2 = card2 <= 9 && card2 >= 0 ? card2 : 0;
  assign val3 = card3 <= 9 && card3 >= 0 ? card3 : 0;
  // add all values and perform modulo 10 operation for total hand score
  assign total = (val1 + val2 + val3) % 10;
endmodule

