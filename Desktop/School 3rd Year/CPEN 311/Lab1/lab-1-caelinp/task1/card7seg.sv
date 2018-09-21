module card7seg(input [3:0] SW, output [6:0] HEX0);
  logic [6:0] HEX;
  initial HEX = 7'b1111111;
  assign HEX0 = HEX;
  always @* begin
    case(SW)
      4'b0001: // switch encoding for Ace
	HEX = 7'b0001000; // hex encoding for ace
      4'b0010: // 2
	HEX = 7'b0100100;
      4'b0011: // 3
	HEX = 7'b0110000;
      4'b0100: // 4
	HEX = 7'b0011001;
      4'b0101: // 5
	HEX = 7'b0010010; 
      4'b0110: // 6
	HEX = 7'b0000010;
      4'b0111: // 7
	HEX = 7'b1111000;
      4'b1000: // 8
	HEX = 7'b0000000;
      4'b1001: // 9
	HEX = 7'b0010000;
      4'b1010: // 10
	HEX = 7'b1000000; // 0 on hex display
      4'b1011: // Jack
	HEX = 7'b1100001; // J on hex display
      4'b1100: // Queen
	HEX = 7'b0011000; // q on hex display 
      4'b1101: // King
	HEX = 7'b0001001; // K on hex display
      default: // all other switch states (including intended blank and unused)
	HEX = 7'b1111111; // map to all hex displays off
    endcase
  end
endmodule

