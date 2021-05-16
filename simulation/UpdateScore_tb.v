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
parameter DISPLAY_MSB 		= (8 * SCORE_DIGITS) - 1;

parameter RST_CYCLES			= 5;
parameter TIMEOUT_CYCLES	= 50 + SCORE_DIGITS;

// declare testbench generated signals
reg	clock;
reg	reset;
reg	enable;

reg	[SCORE_BITWIDTH-1:0]	BCD;
reg	[7:0] 					expectedSegment;
reg	[DISPLAY_MSB-1:0] 	expectedDisplay;

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
integer i;
integer j;
integer k;
integer fail;
integer binary;
integer nibble;
integer random;

// declare local parameter (for BCD to display conversion)
localparam DISPLAY_0 = 4'h0;
localparam DISPLAY_1 = 4'h1;
localparam DISPLAY_2 = 4'h2;
localparam DISPLAY_3 = 4'h3;
localparam DISPLAY_4 = 4'h4;
localparam DISPLAY_5 = 4'h5;
localparam DISPLAY_6 = 4'h6;
localparam DISPLAY_7 = 4'h7;
localparam DISPLAY_8 = 4'h8;
localparam DISPLAY_9 = 4'h9;

//
// define test regime
//
initial begin
	$display("---------------------------------------------");
	$display("Testing: %0d bit UpdateScore module",SCORE_DIGITS);
	$display("---------------------------------------------");
	
	//
	// Update testing
	//
	$display(" ");
	$display("Stage 1: Update testing");
	$display("------------------------");
	reset_testbench();
	
	for (i = 1; i <= ((10**SCORE_DIGITS) - 1); i = i + 1) begin // check counter through full range
		binary = i;
		score_add();
		autoverify_display();
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
	
	for (i = 0; i < 10; i = i + 1) begin	//	check for 10 random values
		score_to_random();		// check value after reset
		reset_dut();
		autoverify_reset();
		
		score_to_random();		// check counting after reseting
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

// add to score value
task score_add ();
begin
	enable = 1;
		@(posedge clock);
	enable = 0;
end
endtask

// wait for BCD counter output and compare to expected behaviour
task autoverify_display();
begin
	fork : f
		// check if counter value matches expected
		begin
			@(posedge ready);
			binary_to_BCD();
			BCD_to_display();
			if (display != expectedDisplay) begin
				fail = 1;
				$display("fail at: \t count = %0d \t exhibited display = %h \t expected display = %h ", binary, display, expectedDisplay);
			end
			disable f;
		end
		
		// check counter finished operation in expected time
		begin
			repeat(TIMEOUT_CYCLES) @(posedge clock);
			fail = 1;
			$display("timeout at: expected count = %0d ", binary);
			disable f;
		end
	join
end
endtask

// convert binary value to BCD using double dabble algorithm 
task binary_to_BCD();
begin
	BCD = 0;
	for (j = 0; j < 32; j = j + 1) begin					// for each bit
		BCD = {BCD[SCORE_BITWIDTH-2:0], binary[31-j]};	//	shift add bit
		
		for (k = 0; k < SCORE_DIGITS; k = k + 1) begin	// check each nibble for where to add 3
			if (j < 31 && BCD[(k * 4)+:4] > 4) begin
				BCD[(k * 4)+:4] = BCD[(k * 4)+:4] + 3;
			end
		end
	end
end
endtask

// convert the BCD value to display
task BCD_to_display();
begin
	for (j = SCORE_DIGITS; j > 0; j = j - 1) begin
		nibble = BCD[(4 * (j - 1)) +:4]; 	// top nibble first
		case (nibble)
			DISPLAY_0	:	expectedSegment = 8'b00111111;
			DISPLAY_1	:	expectedSegment = 8'b00000110;
			DISPLAY_2	:	expectedSegment = 8'b01011011;
			DISPLAY_3	:	expectedSegment = 8'b01001111;
			DISPLAY_4	:	expectedSegment = 8'b01100110;
			DISPLAY_5	:	expectedSegment = 8'b01101101;
			DISPLAY_6	:	expectedSegment = 8'b01111101;
			DISPLAY_7	:	expectedSegment = 8'b00000111;
			DISPLAY_8	:	expectedSegment = 8'b11111111;
			DISPLAY_9	:	expectedSegment = 8'b01100111;
		endcase
		expectedDisplay = {expectedDisplay[DISPLAY_MSB-9:0], expectedSegment};	// shift add nibble to display value
	end
end
endtask

// count to a random score
task score_to_random();
begin
	random = $urandom_range(((100) - 1) ,0); // max range limited to minimise runtime
	for (j = 1; j <= random; j = j + 1) begin
		score_add();
		@(posedge ready);
	end

end
endtask

// check score value after reset
task autoverify_reset();
begin
	binary = 0;
	binary_to_BCD();
	BCD_to_display();
	if (display != expectedDisplay) begin
		fail = 1;
		$display("fail at: \t count = %0d \t exhibited display = %h \t expected display = %h ", binary, display, expectedDisplay);
	end
end
endtask

// check counting ability after reset
task autoverify_reset_2();
begin
binary = random;
	binary_to_BCD();
	BCD_to_display();
	if (display != expectedDisplay) begin
		fail = 1;
		$display("fail at: \t count = %0d \t exhibited display = %h \t expected display = %h ", binary, display, expectedDisplay);
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
