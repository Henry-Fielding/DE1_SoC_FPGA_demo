//
//Hex to seven segment Encoder
//-----------------------------
//By: Henry Fielding
//Date: 14/03/2021
//MOdified: 16/05/2021
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
localparam DISPLAY_0	= 4'h0;
localparam DISPLAY_1	= 4'h1;
localparam DISPLAY_2	= 4'h2;
localparam DISPLAY_3	= 4'h3;
localparam DISPLAY_4	= 4'h4;
localparam DISPLAY_5	= 4'h5;
localparam DISPLAY_6	= 4'h6;
localparam DISPLAY_7	= 4'h7;
localparam DISPLAY_8	= 4'h8;
localparam DISPLAY_9	= 4'h9;

// Case statement to convert input Hexvalve to seven segment display valve
always @ * begin
	case (hex)
		DISPLAY_0	: segments	= 8'b00111111;
		DISPLAY_1	: segments	= 8'b00000110;
		DISPLAY_2	: segments	= 8'b01011011;
		DISPLAY_3	: segments	= 8'b01001111;
		DISPLAY_4	: segments	= 8'b01100110;
		DISPLAY_5	: segments	= 8'b01101101;
		DISPLAY_6	: segments	= 8'b01111101;
		DISPLAY_7	: segments	= 8'b00000111;
		DISPLAY_8	: segments	= 8'b11111111;
		DISPLAY_9	: segments	= 8'b01100111;

		default	: segments	= 8'b01000000; // display - character
	endcase
end
endmodule
