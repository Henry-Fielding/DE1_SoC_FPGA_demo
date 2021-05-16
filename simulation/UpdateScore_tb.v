//
// Update Score Test bench
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 16th May 2021
//
// Short Description
// -----------------
// synchronous test bench designed to autoverifiy the functionality of the update score module
// including counting, reseting and timeout testing.

`timescale 1 ns/100 ps

module UpdateScore_tb;
// declare parameters
parameter CLOCK_FREQ			= 50000000;

parameter SCORE_DIGITS		= 3;
parameter SCORE_BITWIDTH 	= SCORE_DIGITS * 4;
parameter DISPLAY_MSB 		= (8 * SCORE_DIGITS) - 1


parameter RST_CYCLES			= 5;
parameter TIMEOUT_CYCLES	= 50 + COUNTER_DIGITS;

// declare testbench generated signals
reg	clock;
reg	reset;
reg	enable;

// declare dut output signals
wire 							ready;
wire	[DISPLAY_MSB-1:0]	display;


// Instantiate device under test
UpdateScore #(
	.SCORE_DIGITS	(SCORE_DIGITS	)
) DUT (
	// declare ports
	.clock	(clock	),
	.reset	(reset	),
	.enable	(enable	),
	
	.ready	(ready	),
	.display	(display	)
);

// declare testbench variables


//
// define test regime
//
initial begin
	
	$stop;
end

//
// Test bench tasks
//

//
// Synchronous clock logic
//
real HALF_CLOCK_PERIOD = (1e9/ $itor(CLOCK_FREQ))/2.0; // find the clock half-period
integer halfCycles = 0;

// initialise clock to zero
initial begin
	clock = 1'b0;
end

// toggle clock and increment counter after every half timeperiod
always begin
	#(HALF_CLOCK_PERIOD); 
	clock = ~clock;
	halfCycles = halfCycles + 1;
end

endmodule 
