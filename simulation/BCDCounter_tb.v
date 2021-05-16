//
// BCD Counter Test bench
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 15th May 2021
//
// Short Description
// -----------------
// synchronous test bench designed to autoverifiy the functionality of the BCD counter module
// including counting, reseting and timeout testing.

`timescale 1 ns/100 ps

module BCDCounter_tb;
// declare parameters
parameter NUM_CYCLES			= 1000000;
parameter CLOCK_FREQ			= 50000000;

parameter COUNTER_DIGITS	= 3;
parameter COUNTER_BITWIDTH = COUNTER_DIGITS * 4;

parameter RST_CYCLES			= 5;
parameter TIMEOUT_CYCLES	= 50 + COUNTER_DIGITS;

// declare testbench generated signals
reg	clock;
reg	reset;
reg	enable;

// declare dut output signals
wire									ready;
wire	[COUNTER_BITWIDTH-1:0]	countValue;

// Instantiate device under test
BCDCounter #(
	.COUNTER_DIGITS	(COUNTER_DIGITS)
) DUT (
	// declare ports
	.clock	(clock	),
	.reset	(reset	),
	.enable	(enable	),
	
	.ready			(ready		),
	.countValue		(countValue	)
);

// declare testbench variables
integer i;
integer j;
integer fail;
integer expectedCount;
integer binary;
integer random;

//
// define test regime
//
initial begin
	$display("---------------------------------------------");
	$display("Testing: %0d bit binary-coded-decimal counter", COUNTER_DIGITS);
	$display("---------------------------------------------");
	
	//
	// Counter testing
	//
	$display(" ");
	$display("Stage 1: Counter testing");
	$display("------------------------");
	reset_testbench();
	
	for (i = 1; i <= ((10**COUNTER_DIGITS) - 1); i = i + 1) begin // check counter through full range
		counter_add();
		expectedCount = i;
		autoverify_counter();
	end
	
	if (fail) begin
		$display("Failed - see above errors");
	end else begin 
		$display("All tests successful");
	end
	
	//
	// Reset testing
	//
	$display(" ");
	$display("Stage 2: Reset testing");
	$display("----------------------");
	reset_testbench();
	
	for (i = 0; i < 10; i = i + 1) begin
		count_to_random();		// check value after reset
		reset_dut();
		autoverify_reset();
		
		count_to_random();		// check counting after reseting
		expectedCount = random;
		autoverify_reset_2();
	end
	
	if (fail) begin
		$display("Failed - see above errors");
	end else begin 
		$display("All tests successful");
	end
	
	$display(" "); // padding
	$display(" ");
	$display(" ");
	
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
task counter_add ();
begin
	enable = 1;
		@(posedge clock);
	enable = 0;
end
endtask

// wait for BCD counter output and compare to expected behaviour
task autoverify_counter();
begin
	fork : f
		// check if counter value matches expected
		begin
			@(posedge ready);
			BCD_to_binary();
			if (binary != expectedCount) begin
				fail = 1;
				$display("fail at: \t count = %0h \t expected count = %0d ", countValue,  expectedCount);
			end
			disable f;
		end
		
		// check counter finished operation in expected time
		begin
			repeat(TIMEOUT_CYCLES) @(posedge clock);
			fail = 1;
			$display("timeout at: expected count = %0d ", expectedCount);
			disable f;
		end
	join
end
endtask

// convert BCD output back to binary for validation
task BCD_to_binary();
begin
	binary = 0;
	for (j = 0; j < COUNTER_DIGITS; j = j + 1) begin
		binary = binary + ((10**j)*countValue[(j*4)+:4]);
		@(posedge clock);
	end
end
endtask

// increment counter to a random number
task count_to_random();
begin
	random = $urandom_range(((100) - 1) ,0); // max range limited to minimise runtime
	for (j = 1; j <= random; j = j + 1) begin
		counter_add();
		@(posedge ready);
	end

end
endtask

// check counter value after reset
task autoverify_reset();
begin
	if (countValue != 0) begin
		fail = 1;
		$display("fail at: \t count = %h \t expected count = 0 ", countValue);
	end
end
endtask

// check counters ability to count after reset
task autoverify_reset_2();
begin
	BCD_to_binary();
	if (binary != expectedCount) begin
		fail = 1;
		$display("fail at: \t count = %h \t expected count = %d ", countValue,  expectedCount);
	end
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
