// 
// update score
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 14th May 2021
//
// Short Description
// -----------------
// This module is designed to update the score in BCD for 
// the seven segement displays


module UpdateScore #(
	// declare parameters
	parameter SCORE_DIGITS 		= 6,
	parameter SCORE_BITWIDTH 	= 4 * SCORE_DIGITS,
	parameter DISPLAY_MSB 		= (8 * SCORE_DIGITS) - 1
)(
	// declare ports
	input					clock,	// timing ports
	input					reset,
	input					enable,
	
	output							ready,
	output	[DISPLAY_MSB:0]	display
);

// declare local wire/reg
wire	[(SCORE_BITWIDTH-1):0]	countValue;

//
// instantiate modules
//
BCDCounter #(
	// define parameters
	.COUNTER_DIGITS	(SCORE_DIGITS	)
) counter (
	// define ports
	.clock		(clock		),
	.reset		(reset		),
	.enable		(enable		),
	
	.ready		(ready		),
	.countValue	(countValue	)
);

HexTo7SegmentNBit #(
	// define parameters
	.DISPLAYS	(SCORE_DIGITS	)
) converter (
	// define ports
	.hex		(countValue	),
	.display	(display		)
);

endmodule 


