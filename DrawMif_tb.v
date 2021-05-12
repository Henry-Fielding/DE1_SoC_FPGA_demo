/*
 * Draw Mif Test bench
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 12th May 2021
 *
 * Short Description
 * -----------------
 * synchronous test bench designed to autoverifiy the functionality of the DrawMif module
 *
 */

`timescale 1 ns/100 ps

module DrawMif_tb;

//
// Variable Declarations
//

// declare parameters
parameter NUM_CYCLES = 1000;
parameter CLOCK_FREQ = 50000000;
parameter RST_CYCLES = 5;

// declare testbench generated signals
reg clock;
reg reset;

reg	[15:0]	xOrigin;
reg	[15:0]	yOrigin;
reg	[ 7:0]	mifId;
reg				draw;

// declare dut output signals
wire				LT24Wr_n,
wire				LT24Rd_n,
wire				LT24CS_n,
wire				LT24RS,
wire				LT24Reset_n,
wire	[15:0]	LT24Data,
wire				LT24LCDOn		

//
// Module Instantiations
//

// Instantiate device under test
DrawMif #(
	// define parameters
	.CLCOK_FREQ	(CLOCK_FREQ	),
) DrawMif_dut (
	// define port connections
	.clock		(clock		)
	.reset		(reset		)
	.xOrigin		(xOrigin		),
	.yOrigin		(yOrigin		),
	.mifId		(mifId		),
	.draw			(draw			)
	
	.ready		(ready		),
	.LT24Wr_n	(LT24Wr_n	),
	.LT24Rd_n	(LT24Rd_n	),
	.LT24CS_n	(LT24CS_n	),
	.LT24RS		(LT24RS		),
	.LT24Reset_n(LT24Reset_n),
	.LT24Data	(LT24Data	),
	.LT24LCDOn	(LT24LCDOn	),
	
	.LEDs			(				) // temporary/unused	
);

//	Instantiate LCD model
LT24FunctionalModel #(
	// define parameters
	.WIDTH	(240	)
	.HEIGHT	(320	)
) DisplayModel (
	// define port connections
	.LT24Wr_n	(LT24Wr_n	),
	.LT24Rd_n	(LT24Rd_n	),
	.LT24CS_n	(LT24CS_n	),
	.LT24RS		(LT24RS		),
	.LT24Reset_n(LT24Reset_n),
	.LT24Data	(LT24Data	),
	.LT24LCDOn	(LT24LCDOn	),
);

//
// Test Bench Logic
//

