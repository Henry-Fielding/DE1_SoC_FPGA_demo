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
wire				ready;
wire				LT24Wr_n;
wire				LT24Rd_n;
wire				LT24CS_n;
wire				LT24RS;
wire				LT24Reset_n;
wire	[15:0]	LT24Data;
wire				LT24LCDOn;	

//temp
wire [7:0] imgWidth;
wire [8:0] imgHeight;
	
//
// Module Instantiations
//

// Instantiate device under test
DrawMif #(
	// define parameters
	.CLOCK_FREQ	(CLOCK_FREQ	)
) DrawMif_dut (
	// define port connections
	.clock		(clock		),
	.reset		(reset		),
	.xOrigin		(xOrigin		),
	.yOrigin		(yOrigin		),
	.mifId		(mifId		),
	.draw			(draw			),
	
	.ready		(ready		),
	.LT24Wr_n	(LT24Wr_n	),
	.LT24Rd_n	(LT24Rd_n	),
	.LT24CS_n	(LT24CS_n	),
	.LT24RS		(LT24RS		),
	.LT24Reset_n(LT24Reset_n),
	.LT24Data	(LT24Data	),
	.LT24LCDOn	(LT24LCDOn	),
	
	.imgWidth		(imgWidth),
	.imgHeight		(imgHeight),
	.LEDs			(				) // temporary/unused	
);

//	Instantiate LCD model
LT24FunctionalModel #(
	// define parameters
	.WIDTH	(240	),
	.HEIGHT	(320	)
) DisplayModel (
	// define port connections
	.LT24Wr_n	(LT24Wr_n	),
	.LT24Rd_n	(LT24Rd_n	),
	.LT24CS_n	(LT24CS_n	),
	.LT24RS		(LT24RS		),
	.LT24Reset_n(LT24Reset_n),
	.LT24Data	(LT24Data	),
	.LT24LCDOn	(LT24LCDOn	)
);

//
// Test Bench Logic
//

initial begin
	
	$display("MIF 1 draw testing");
	reset_dut();		// return dut to know state
	draw <= 1'd0;
	@(posedge ready)	// wait for dut to be ready
	
	xOrigin <= 16'd10;
	yOrigin <= 16'd10;
	mifId <= 8'd0;
	draw <= 1'd1;
	
	@(negedge ready)
	draw <= 1'd0;

end

//
// Test bench tasks
//

task reset_dut() ;
begin
	// initialise in reset, clear reset after preset number of clock cycles
	reset = 1'b1;
	repeat(RST_CYCLES) @(posedge clock);
	reset = 1'b0;
	repeat(RST_CYCLES) @(posedge clock);
end
endtask


//
// Synchronous clock logic
//

initial begin
	// initialise clock to zero
	clock = 1'b0;
end

real HALF_CLOCK_PERIOD = (1e9/ $itor(CLOCK_FREQ))/2.0; // find the clock half-period
integer halfCycles = 0;

always begin
	// toggle clock and increment counter after every half timeperiod
	#(HALF_CLOCK_PERIOD); 
	clock = ~clock;
	halfCycles = halfCycles + 1;
end

endmodule 


