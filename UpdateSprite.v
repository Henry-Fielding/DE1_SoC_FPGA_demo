/*
 * Update player position
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 13th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to update the player position based on user inputs
 *
 */

module UpdateSprite (
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
localparam	STAND_STATE		=	4'd0;
localparam	RUN_STATE		=	4'd1;
localparam	JUMP_STATE		=	4'd2;
localparam	CROUCH_STATE	=	4'd3;

always @(posedge update or posedge reset) begin
	if (reset) begin
		state <= 4'd1;
	end else begin
		case (state)
			RUN_STATE : begin
				xSprite <= 8'd95;
				ySprite <= 9'd119;
				//task to update ROMid
				//if button pressed move to jump
				update_running_animation();
				
				if (!keys[0]) begin
					state <= JUMP_STATE;
				end
				if (!keys[1]) begin
					state <= CROUCH_STATE;
				end
			end
			
			JUMP_STATE : begin
				xSprite <= 8'd95;
				ySprite <= 9'd119;
				spriteId <= 4'd3;
				//	adjust height 
				//	if height = floor move to run
				if (keys[0]) begin
					state <= RUN_STATE;
				end
			end
			
			CROUCH_STATE : begin
				xSprite <= 8'd95;
				ySprite <= 9'd119;
				spriteId <= 4'd4;
				//	adjust height 
				//	if height = floor move to run
				if (keys[1]) begin
					state <= RUN_STATE;
				end
			end
			
		endcase
	end
end

task update_running_animation () ;
	if (spriteId < 4'd2) begin
		spriteId <= spriteId + 4'd1;
	end else begin
		spriteId <= 4'd0;
	end

endtask

endmodule 