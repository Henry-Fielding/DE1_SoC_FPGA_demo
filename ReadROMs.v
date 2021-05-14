/*
 * Read ROMs
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 13th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to read the data stored at the given address in the selected ROM module
 *
 */

module ReadROMs (
	// declare ports
	input 			clock,	// timing ports
	input 			reset,
	input [ 3:0]	ROMId,	// general ports
	input	[15:0]	ROMAddr,
	
	output reg	[15:0]	ReadROMOut
);

//
// Declare local registers/wires
//
wire	[15:0]	ROMOutBus	[15:0];

//
// Instatiate modules
//
MarioWalk1	ROM0 (
	// define port connections
	.clock 	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[0]	)
);

MarioWalk2	ROM1 (
	// define port connections
	.clock 	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[1]	)
);

MarioWalk3	ROM2 (
	// define port connections
	.clock 	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[2]	)
);

MarioJump	ROM3 (
	// define port connections
	.clock 	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[3]	)
);

MarioCrouch	ROM4 (
	// define port connections
	.clock 	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[4]	)
);

Floor	ROM5 (
	// define port connections
	.clock 	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[5]	)
);

FloorTile1 ROM6 (
	// define port connections
	.clock 	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[6]	)
);

Background	ROM15 (
	// define port connections
	.clock 	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[15]	)
);

//
// Declare module logic
//

always @(posedge clock) begin
	ReadROMOut <= ROMOutBus[ROMId];
end

endmodule
		