//
// Update lives (N lives)
// ----------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 17th May 2021
//
// Short Description
// -----------------
// This module is a counter designed to update the player lives based on the max lives and collisions
// and display them as an LED output.


module UpdateLivesNLives #(
	parameter MAX_LIVES	= 3
)(
	// declare ports
	input		clock,
	input		reset,
	input		enable,
	
	output reg			ready,
	output reg 			gameOver,
	output reg [9:0]	LEDs
);

//
// declare statemachine registers and statenames
//
// top level statemachine
reg [3:0] state					= 4'd0;
localparam IDLE_STATE			= 4'd0;
localparam READY_STATE			= 4'd1;
localparam CHECK_LIVES_STATE	= 4'd2;
localparam GAMEOVER_STATE		= 4'd3;

// lives to LEDs substatemachine
reg [3:0] lives 	= MAX_LIVES;	
localparam LEDs_0	= 4'd0;
localparam LEDs_1	= 4'd1;
localparam LEDs_2	= 4'd2;
localparam LEDs_3	= 4'd3;
localparam LEDs_4	= 4'd4;
localparam LEDs_5	= 4'd5;
localparam LEDs_6	= 4'd6;
localparam LEDs_7	= 4'd7;
localparam LEDs_8	= 4'd8;
localparam LEDs_9	= 4'd9;
localparam LEDs_10= 4'd10;

//
// define statemachine behaviour
//
always @(posedge clock or posedge reset) begin
	if (reset) begin
		ready		<= 1'd0;
		gameOver	<= 1'd0;
		lives		<= MAX_LIVES;
		state		<= IDLE_STATE;
		
	end else begin
		case (state)
			//	wait to enable input to be disabled
			IDLE_STATE : begin
				ready	<= 1'd1;

				if (!enable) begin
					state	<= READY_STATE;
				end
			end
			
			// decrements lives when enable bit set
			READY_STATE : begin
				ready	<= 1'd1;
				
				if (enable) begin
					ready	<= 1'd0;
					lives <= lives - 1'd1;
					state	<= CHECK_LIVES_STATE;
				end
			end
			
			// check if player lives is greater than zero
			CHECK_LIVES_STATE : begin
				if (lives > 0) begin
					state	<= IDLE_STATE;
				end else begin
					state	<= GAMEOVER_STATE;
				end		
			end
			
			// set gameover bit and wait for module reset
			GAMEOVER_STATE : begin
				ready <= 1'd1;
				gameOver <= 1'd1;
			end	
		endcase
	end
end

//
// define substate machine behaviour
//
always @(posedge clock) begin
	// display player lives on LEDs
	case (lives)
		LEDs_0	:	LEDs = 10'b0000000000;
		LEDs_1	:	LEDs = 10'b0000000001;
		LEDs_2	:	LEDs = 10'b0000000011;
		LEDs_3	:	LEDs = 10'b0000000111;
		LEDs_4	:	LEDs = 10'b0000001111;
		LEDs_5	:	LEDs = 10'b0000011111;
		LEDs_6	:	LEDs = 10'b0000111111;
		LEDs_7	:	LEDs = 10'b0001111111;
		LEDs_8	:	LEDs = 10'b0011111111;
		LEDs_9	:	LEDs = 10'b0111111111;
		LEDs_10	:	LEDs = 10'b1111111111;
		
		default	:	LEDs = 10'b0000000000;
	endcase
end	

endmodule 