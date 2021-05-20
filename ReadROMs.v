//
// Read ROMs
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 13th May 2021
//
// Short Description
// -----------------
// This module outputs RGB565 pixel data stored at the input address in the 
// selected ROM module, functioning as a 16 bit mulitplexer. 
// Unused ROMids output 0x0000 for all input addresses.


module ReadROMs (
	// declare ports
	input				clock,
	input				reset,
	input	[ 3:0]	ROMId,
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
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[0]	)
);

MarioWalk2	ROM1 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[1]	)
);

MarioWalk3	ROM2 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[2]	)
);

MarioJump	ROM3 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[3]	)
);

MarioCrouch	ROM4 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[4]	)
);

FloorTile	ROM5 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[5]	)
);

Goomba1 ROM6 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[6]	)
);

Goomba2 ROM7 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[7]	)
);

BulletBill ROM8 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[8]	)
);

IntroScreen ROM9 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[9]	)
);

GameOverScreen ROM10 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[10]	)
);

Background	ROM11 (
	// define port connections
	.clock	(clock			),
	.address	(ROMAddr			),
	.q			(ROMOutBus[11]	)
);

// assign known value to unused multiplexer inputs
assign ROMOutBus[12] = 16'd0;
assign ROMOutBus[13] = 16'd0;
assign ROMOutBus[14] = 16'd0;
assign ROMOutBus[15] = 16'd0;

//
// Declare module logic
//
always @(posedge clock) begin
	ReadROMOut	<= ROMOutBus[ROMId];	// connects the module output to the desired ROM module
end

endmodule 