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
	input	[3:0]			speed,
	input [7:0]			randomSeed,
	
	output reg	[ 7:0]	xSprite,
	output reg	[ 8:0]	ySprite,
	output reg	[ 3:0] 	obstacleId, //
	output reg				passed
);

reg	[7:0] ROMAddr;
wire			randomNumber;

RandomNumbers	ROM (
	// define port connections
	.clock 	(update			),
	.address	(ROMAddr			),
	.q			(randomNumber	)
);
//
// Declare statemachine registers and parameters
//
reg	[3:0]	state;
localparam	RESET_POSITION_STATE		=	4'd0;
localparam	UPDATE_POSITION_STATE		=	4'd1;

always @(posedge update or posedge reset) begin
	if (reset) begin
		state <= RESET_POSITION_STATE;
		passed <= 1'b0;
		ROMAddr <= randomSeed;
	end else begin
		case (state)
			RESET_POSITION_STATE : begin // reset to left of screen 
				passed <= 1'b0;
				ySprite <= 419;
				// if random = 1 deploy high
				// else deploy low
				if (randomNumber) begin
					xSprite <= 110;
					obstacleId <= 8;
				end else begin
					xSprite <= 63;
					obstacleId <= 6;
				end

				state <= UPDATE_POSITION_STATE;
				ROMAddr <= ROMAddr + 1;
			end
			
			UPDATE_POSITION_STATE : begin // gradually move left
				passed <= 1'b0;
				ySprite <= ySprite - speed;
				
				if (obstacleId == 6) begin
					obstacleId <= 7;
				end else if (obstacleId == 7) begin
					obstacleId <= 6;
				end
				
				if (ySprite <= 36 + (2*speed)) begin
					state <= RESET_POSITION_STATE;
					passed <= 1'b1;
				end
			end
		endcase
	end
end

endmodule
