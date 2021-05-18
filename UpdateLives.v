//
// Update player lives
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 17th May 2021
//
// Short Description
// -----------------
// This module is designed to update the player lives


module UpdateLives #(
	parameter MAX_LIVES			= 3;
	parameter LIVES_BITWIDTH	= $clog2(MAX_LIVES + 1)
)(
	// declare ports
	input						clock,
	input						reset,
	input						enable,
	
	output reg 				gameOver,
	output reg	[ 9:0]	LEDs
);

// declare local registers
reg [(LIVES_BITWIDTH-1):0] lives

// declare statemachine registers and statenames
reg [3:0] state;
localparam IDLE_STATE		= 4'd0;
localparam READY_STATE		= 4'd1;
localparam CHECK_LIVES_STATE		= 4'd1;
localparam GAMEOVER_STATE	= 4'd2;

//
// define statemachine behaviour
//
always @(posedge clock or posedge reset) begin
	if (reset) begin
		gameOVer	<= 1'b0;
		lives		<= MAX_LIVES;
		
	end else begin
		case (state)
			//	wait to enable input to be disabled
			IDLE_STATE : begin
				ready	<= 1'b1;
				LEDs	<= lives;
				
				if (!enable) begin
					state	<= READY_STATE;
				end
			end
			
			// decrements lives when enable bit set
			READY_STATE : begin
				ready	<= 1'b1;
				LEDs	<= lives;
				
				if (enable) begin
					ready	<= 1'b0;
					lives <= lives - 1;
					state	<= UPDATE_STATE;
				end
			end
			
			//
			CHECK_LIVES_STATE : begin
				if (lives > 0) begin
					state	<= IDLE_STATE;
				end else begin
					state	<= GAMEOVER_STATE;
				end		
			end
			
			// set gameover bit and wait for module reset
			GAMEOVER_STATE : begin
				gameOver <= 1;
			end	
end

endmodule 