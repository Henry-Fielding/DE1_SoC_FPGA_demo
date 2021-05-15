/*
 * Draw BCD Counter Test bench
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 15th May 2021
 *
 * Short Description
 * -----------------
 * synchronous test bench designed to autoverifiy the functionality of the BCD counter module
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
reg 	clock;
reg 	reset;
reg	enable;

// declare dut output signals
wire	countValue;

//
// Module Instantiations
//
// Instantiate device under test
BCDCounter #(
	.SCORE_BITWIDTH	(24			),
) dut (
	// declare ports
	.clock				(clock		),
	.reset				(reset		),
	.enable				(enable		),
	
	.countValue			(countValue	)
);

//
// Test Bench Logic
//
initial begin
	
	$display("BCD testing");
	reset_dut();		// return dut to know state

	
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
