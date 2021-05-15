/* BCD counter
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 15th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to count up in binary coded decimal
 *
 */

module BCDCounter #(
	parameter SCORE_BITWIDTH = 24;
	parameter SCORE_NIBBLES = SCORE_BITWIDTH / 4;
	parameter NIBBLE_COUNTER_BITWIDTH = $clog2(SCORE_NIBBLES + 1)
)(
	// declare ports
	input					clock,	// timing ports
	input					reset,
	input					enable,
	
	//output reg	[SCORE_BITWIDTH-1:0]	totalScoreOutput
	output reg	[23:0]	countValueOut
);


//reg [NIBBLE_COUNTER_BITWIDTH-1:0] nibbleCounter;
reg [23:0] countValueTemp;
//
//localparam ZERO_SCORE = {(SCORE_BITWIDTH){1'd0}};
//localparam ONE_SCORE = {{(SCORE_BITWIDTH-1){1'd0}}, 1'd0};
//localparam SIX_SCORE = {{(SCORE_BITWIDTH-3){1'd0}}, 3'd6};
//localparam ZERO_NIBBLE_COUNTER = {(NIBBLE_COUNTER_BITWIDTH){1'd0}};
//localparam ONE_NIBBLE_COUNTER = {{(NIBBLE_COUNTER_BITWIDTH-1){1'd0}}, 1'd0};

reg [3:0] state;
localparam IDLE_STATE = 4'd0;
localparam READY_STATE = 4'd1;
localparam UPDATE_SCORE_STATE = 4'd2;
localparam EXAMINE_NIBBLES_STATE = 4'd3;
localparam UPDATE_OUTPUT_STATE = 4'd4;

//always @(posedge clock) begin
//	totalScoreOutput <= 24'h0000AA;
//
//end

always @(posedge clock or posedge reset) begin
	if (reset) begin
		//totalScore <= ZERO_SCORE;
		//totalScoreOutput <= ZERO_SCORE;
		totalScore <= 24'd0;
		totalScoreOutput<= 24'd0;
		//nibbleCounter <= ZERO_NIBBLE_COUNTER;
		state <= IDLE_STATE;
	end else begin
		case (state)
			IDLE_STATE : begin
				ready <= 1'd1;
				//totalScore <= 24'h0000AA;
//				state <= UPDATE_OUTPUT_STATE;
				if (!enable) begin
					state <= READY_STATE;
				end
			end
			
			READY_STATE : begin
				ready <= 1'd1;
				if (enable) begin
					ready <= 1'd0;
					totalScoreOutput <= totalScoreOutput + 1;
					state <= IDLE_STATE;
				end
			end
//			
//			UPDATE_SCORE_STATE : begin
//				if (score) begin
//					totalScore <= totalScore + 1;//ONE_SCORE;
//					nibbleCounter <= ZERO_NIBBLE_COUNTER;
//					state <= EXAMINE_NIBBLES_STATE;
//				end else begin
//					state <= IDLE_STATE;
//				end
//			end
//			
//			EXAMINE_NIBBLES_STATE : begin
//				if(totalScore[(nibbleCounter*4)+:4] > 9) begin
//					totalScore <= totalScore + (6 << (nibbleCounter*4));//SIX_SCORE;
//				end
//				nibbleCounter <= nibbleCounter + ONE_NIBBLE_COUNTER;
//		
//				if (nibbleCounter > SCORE_NIBBLES) begin
//					state <= UPDATE_OUTPUT_STATE;
//				end else begin
//					state <= EXAMINE_NIBBLES_STATE;
//				end
//			end
			
//			UPDATE_OUTPUT_STATE : begin
//				totalScoreOutput <= ;
//				state <= IDLE_STATE;
//			end
		endcase
	end
end

endmodule