// 
// BCD counter
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 15th May 2021
//
// Short Description
// -----------------
// This module is designed to count up in binary coded decimal

module BCDCounter #(
	// declare parameters
	parameter COUNTER_DIGITS				= 6,
	parameter COUNTER_BITWIDTH				= COUNTER_DIGITS * 4,
	parameter NIBBLE_COUNTER_BITWIDTH	= $clog2(COUNTER_DIGITS + 2)
)(
	// declare ports
	input		clock,
	input		reset,
	input		enable,
	
	output reg 									ready,
	output reg	[COUNTER_BITWIDTH-1:0]	countValue
);

// declare local registers
reg	[COUNTER_BITWIDTH-1:0] 				countValueTemp;
reg	[NIBBLE_COUNTER_BITWIDTH-1:0]		nibbleCounter;
//reg	[32:0]		nibbleCounter;
reg	[3:0] 									nibble;

// declare local parameters
localparam ZERO_COUNT				= {(COUNTER_BITWIDTH){1'd0}};
localparam ONE_COUNT					= {{(COUNTER_BITWIDTH-1){1'd0}}, 1'd1};
localparam ZERO_NIBBLE_COUNTER	= {(NIBBLE_COUNTER_BITWIDTH){1'd0}};
localparam ONE_NIBBLE_COUNTER		= {{(NIBBLE_COUNTER_BITWIDTH-1){1'd0}}, 1'd1};

// declare state machine registers and statenames
reg	[3:0]	state;
localparam IDLE_STATE				= 4'd0;
localparam READY_STATE				= 4'd1;
localparam EXAMINE_NIBBLES_STATE	= 4'd3;
localparam UPDATE_OUTPUT_STATE	= 4'd4;

//
// define statemachine behaviour
//
always @(posedge clock or posedge reset) begin
	if (reset) begin
		ready				<= 1'b0;
		countValueTemp	<= ZERO_COUNT;
		countValue		<= ZERO_COUNT;
		state				<= IDLE_STATE;
		
	end else begin
		case (state)
			//	wait to enable input to be disabled
			IDLE_STATE : begin		
				if (!enable) begin
					state <= READY_STATE;
				end
			end
			
			// increment counter when enable bit set
			READY_STATE : begin		
				ready <= 1'b1;
				
				if (enable) begin
					ready				<= 1'b0;
					countValueTemp	<= countValueTemp + ONE_COUNT;
					nibbleCounter	<= ZERO_NIBBLE_COUNTER;
					state				<= EXAMINE_NIBBLES_STATE;
				end
			end
			
			// check each nibble for 'BCD overflow' (nibble > 9)
			EXAMINE_NIBBLES_STATE : begin
				nibbleCounter <= nibbleCounter + ONE_NIBBLE_COUNTER;					// increment nibble
				if(countValueTemp[(nibbleCounter * 4)+:4] > 9) begin					// check if current nibble is > 9
					countValueTemp <= countValueTemp + (6 << (nibbleCounter * 4));	// if so add 6 to the offending nibble
				end
				
				if (nibbleCounter > COUNTER_DIGITS) begin
					state <= UPDATE_OUTPUT_STATE;
				end
			end
			
			// update output BCD value
			UPDATE_OUTPUT_STATE : begin
				countValue	<= countValueTemp;
				state			<= IDLE_STATE;
			end
		endcase
	end
end

endmodule