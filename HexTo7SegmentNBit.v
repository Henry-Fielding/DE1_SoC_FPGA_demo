//
//N-bit Hex to seven segment Encoder
//-----------------------------
//By: Henry Fielding
//Date: 14/03/2021
//
//Description
//------------
// A module to Encode a N bit hex value for display on a seven segment displays

module HexTo7SegmentNBit #(
	// declare parameters
	parameter DISPLAYS = 6,
	parameter HEX_MSB = (4 * DISPLAYS) - 1,
	parameter DISPLAY_MSB = (8 * DISPLAYS) - 1
)(
	// declare ports
	input		[HEX_MSB:0		]	hex,
	output	[DISPLAY_MSB:0	]	display
);

genvar i;

generate
	// instantiate a HexTo7Segment encoders for each seven segment displays
	for (i = 1; i <= DISPLAYS; i = i + 1) begin : encoder_loop
		HexTo7Segment encoder (
			// define connections
			.hex 			(hex		[(4 * i) - 1 -: 4]	),
			.segments	(display	[(8 * i) - 1 -: 8]	)
		);
	end
endgenerate
endmodule 