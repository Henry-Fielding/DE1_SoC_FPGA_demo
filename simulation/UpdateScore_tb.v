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
reg [SCORE_BITWIDTH-1:0] BCD;
reg [7:0] expectedSegment;
reg [DISPLAY_MSB-1:0] expectedDisplay;
integer i;
integer j;
integer k;
integer binary;
integer nibble;

integer fail;

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
		@(posedge ready) 
		
		// binary to bcd
		BCD = 0;
		for (j = 0; j < 32; j = j + 1) begin
			BCD = {BCD[SCORE_BITWIDTH-2:0], binary[31-j]};
			
			// check each bit
			for (k = 0; k < SCORE_DIGITS; k = k + 1) begin
				if (j < 31 && BCD[(k * 4)+:4] > 4) begin
					BCD[(k * 4)+:4] = BCD[(k * 4)+:4] + 3;
				end
			end
		end
		
		//BCD to display
		for (j = SCORE_DIGITS; j > 0; j = j - 1) begin
			nibble = BCD[(4 * (j - 1)) +:4]; // top nibble first
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
			expectedDisplay = {expectedDisplay[DISPLAY_MSB-9:0], expectedSegment};// bottom end of BCD
		end
		
	end
		
		
		
		
		
		
		
		//autoverify_display();

	
//	if (fail) begin
//		$display("Failed - see above errors");
//	end else begin 
//		$display("All tests successful");
//	end
	
//	//
//	// Reset testing
//	//
//	$display(" ");
//	$display("Stage 2: Reset testing");
//	$display("----------------------");
//	reset_testbench();
//	
	
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

//// wait for BCD counter output and compare to expected behaviour
//task autoverify_counter();
//begin
//	fork : f
//		// check if counter value matches expected
//		begin
//			@(posedge ready);
//			binary_to_BCD();
//			BCD_to_display();
//			if (display != expectedDisplay) begin
//				fail = 1;
//				$display("fail at: \t count = %0h \t expected count = %0d ", countValue,  expectedCount);
//			end
//			disable f;
//		end
//		
//		// check counter finished operation in expected time
//		begin
//			repeat(TIMEOUT_CYCLES) @(posedge clock);
//			fail = 1;
//			$display("timeout at: expected count = %0d ", expectedCount);
//			disable f;
//		end
//	join
//end
//endtask


task binary_to_BCD();
begin 

		
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