//
// Update Lives Test bench
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 18th May 2021
//
// Short Description
// -----------------
// synchronous test bench designed to autoverifiy the functionality of the update lives module
// including decrementing and reseting.

`timescale 1 ns/100 ps

module UpdateLives_tb;
// declare parameters
parameter NUM_CYCLES			= 1000000;
parameter CLOCK_FREQ			= 50000000;

parameter MAX_LIVES			= 3;
parameter LIVES_BITWIDTH 	= 4 * MAX_LIVES;

parameter RST_CYCLES			= 5;
parameter TIMEOUT_CYCLES	= 50;

// declare testbench generated signals
reg	clock;
reg	reset;
reg	enable;

// declare dut output signals
wire			ready;
wire			gameOver;
wire [ 9:0]	LEDs;


wire [3:0] lives;
// Instantiate device under test
UpdateLives #(
	.MAX_LIVES	(MAX_LIVES)
) DUT (
	// declare ports
	.clock	(clock	),
	.reset	(reset	),
	.enable	(enable	),
	
	.ready		(ready		),
	.gameOver	(gameOver	),
	.LEDs			(LEDs			),
	.lives		(lives			)
);

// declare testbench variables
integer i;
integer j;
integer fail;
integer expectedCount;
integer binary;
integer random;
integer expectedLEDs;

//
// define test regime
//
initial begin
	$display("---------------------------------------------");
	$display("Testing: Update lives counter (%0d lives max)", MAX_LIVES);
	$display("---------------------------------------------");
	
	//
	// Counter testing
	//
	$display(" ");
	$display("Stage 1: Decrement testing");
	$display("------------------------");
	reset_testbench();
	
	for (i = 1; i <= MAX_LIVES; i = i + 1) begin
		@(posedge clock);
		decrement_lives();
		@(posedge ready);
		
		// check the correct output value 
	end
	
	repeat(5)@(posedge clock)
	
	
	
	
	
	
	$stop;
end

//
// Test bench tasks
//

// return testbench to a known state
task reset_testbench();
begin
	enable	= 0;
	fail 		= 0;
	reset_dut();
end
endtask

// reset the device for RST_CYCLES
task reset_dut();
begin
	reset = 1'b1;
	repeat(RST_CYCLES) @(posedge clock);
	reset = 1'b0;
	repeat(RST_CYCLES) @(posedge clock);
end
endtask

// add to counter value
task decrement_lives ();
begin
	enable = 1;
		@(posedge clock);
	enable = 0;
end
endtask


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
