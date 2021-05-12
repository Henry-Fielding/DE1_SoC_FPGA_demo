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

module ROMREADTEST_tb;

//
// Variable Declarations
//

// declare parameters
parameter NUM_CYCLES = 1000;
parameter CLOCK_FREQ = 50000000;
parameter RST_CYCLES = 5;

// declare testbench generated signals
reg clock;
reg [7:0] addr;



// declare dut output signals
reg						ready;
wire		[15:0]		read;

	
//
// Module Instantiations
//
// Instantiate device under test
ROMREADTEST	ROM_dut(
	.clock ( clock ),
	.addr ( addr ),
	.ready ( ready ),
	.read ( read )

	);

//
// Test Bench Logic
//

initial begin
	
	$display("testing");
	ready<= 1'd0;

	addr <= 8'd0;

	repeat(5) @(posedge clock);
	ready<= 1'd1;
	repeat(5) @(posedge clock);
	
	addr <= 8'd1;
	
	repeat(5) @(posedge clock);
	
	addr <= 8'd2;
	
	repeat(5) @(posedge clock);

end

//
// Test bench tasks
//

//task reset_dut() ;
//begin
//	// initialise in reset, clear reset after preset number of clock cycles
//	reset = 1'b1;
//	repeat(RST_CYCLES) @(posedge clock);
//	reset = 1'b0;
//	repeat(RST_CYCLES) @(posedge clock);
//end
//endtask


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