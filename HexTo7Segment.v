//
//Hex to seven segment Encoder
//-----------------------------
//By: Henry Fielding
//Date: 14/03/2021
//
//Description
//------------
// A module to Encode a 1 bit hex value for display on a seven segment displays

module HexTo7Segment (
	// Declare ports
	input			[3:0]	hex,
	output reg	[7:0]	segments
);

// define case names
localparam DISPLAY_0 = 4'h0;
localparam DISPLAY_1 = 4'h1;
localparam DISPLAY_2 = 4'h2;
localparam DISPLAY_3 = 4'h4;
localparam DISPLAY_4 = 4'h8;

localparam DISPLAY_E = 4'hC;
localparam DISPLAY_r = 4'hD;
localparam DISPLAY_o = 4'hE;

localparam DISPLAY_BLANK = 4'hF;

// Case statement to convert input Hexvalve to seven segment display valve
always @ * begin
	case (hex)
		DISPLAY_0	:	segments = 8'b00111111;
		DISPLAY_1	:	segments = 8'b00000110;
		DISPLAY_2	:	segments = 8'b01011011;
		DISPLAY_3	:	segments = 8'b01001111;
		DISPLAY_4	:	segments = 8'b01100110;

		DISPLAY_E	:	segments = 8'b01111001;
		DISPLAY_r	:	segments = 8'b01010000;
		DISPLAY_o	:	segments = 8'b01011100;
		DISPLAY_BLANK	:	segments = 8'b00000000;

		default:	segments = 8'b01000000; // display - character
	endcase
end
endmodule
