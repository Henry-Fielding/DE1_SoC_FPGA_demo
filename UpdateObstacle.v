/* update obstacle position
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 13th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to update the position of the obstacle
 *
 */

module UpdateObstacle (
	// declare ports
	input					update,	// timing ports
	input					reset,
	input		[ 3:0]	keys,		// general ports
	
	output reg	[ 7:0]	xSprite,
	output reg	[ 8:0]	ySprite,
	output reg	[ 3:0] 	spriteId
);

//
// Declare statemachine registers and parameters
//
reg	[3:0]	state;
localparam	WAIT_RANDOM_STATE		=	4'd0;
localparam	RESET_POSITION_STATE		=	4'd1;
localparam	UPDATE_POSITION_STATE		=	4'd2;

always @(posedge update or posedge reset) begin
	if (reset) begin
		state <= RESET_POSITION_STATE;
	end else begin
		case (state)
			WAIT_RANDOM_STATE : begin // wait a random amount of time before deploying obstacle
				//unused
			
			end
			
			RESET_POSITION_STATE : begin // reset to left of screen 
				xSprite <= 63; 
				ySprite <= 419;
				
				state <= UPDATE_POSITION_STATE;
			end
			
			UPDATE_POSITION_STATE : begin // gradually move left
				ySprite <= ySprite - 4;
				
				if (ySprite <= 68) begin
					state <= RESET_POSITION_STATE;
				end
			end
		endcase
	end
end

endmodule 