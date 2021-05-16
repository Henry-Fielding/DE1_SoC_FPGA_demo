//
// Update Score Hardware testing
// -----------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 16th May 2021
//
// Short Description
// -----------------
// synchronous test bench designed to autoverifiy the functionality of the update score module
// including counting, reseting and timeout testing in hardware.

module updateScore_tbHardware #(
	parameter SCORE_DIGITS		= 3,
	parameter SCORE_BITWIDTH	= SCORE_DIGITS * 4,
	parameter DISPLAY_MSB 		= (8 * SCORE_DIGITS) - 1
) (
	input clock,
	input [3:0] keys,
	
	output		[9:0]		LEDs,
	output reg 	[6:0] 	display1,
	output reg 	[6:0] 	display2,
	output reg 	[6:0] 	display3
);

wire [DISPLAY_MSB:0] display;

// Instantiate device under test
UpdateScore #(
	.SCORE_DIGITS	(3	)
) DUT (
	// declare ports
	.clock	(clock	),
	.reset	(!keys[1]	),
	.enable	(!keys[0]	),
	
	.ready	(LEDs[0]		),
	.display	(display		)
);


always @(posedge clock) begin
	display1 <= ~display [6:0];
	display2 <=	~display [14:8];
	display3 <= ~display [22:16];
end
endmodule 