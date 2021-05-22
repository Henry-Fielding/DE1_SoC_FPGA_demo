//
// Update player sprite
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 13th May 2021
//
// Short Description
// -----------------
// This module is designed to update the player characters position and sprite variation
// (jump, run , crouch, ect) based on user inputs and game timing.

module UpdateSprite (
	// declare ports
	input				update,
	input				reset,
	input	[ 3:0]	keys,
	
	output reg	[ 7:0]	xSprite,
	output reg	[ 8:0]	ySprite,
	output reg	[ 3:0]	IdSprite
);

//
// Declare local registers.wires
//
reg signed	[7:0]	velocity;

//
// Declare statemachine registers and parameters
//
reg	[3:0]	state				= 4'd0;
localparam	RUN_STATE		= 4'd0;
localparam	CROUCH_STATE	= 4'd1;
localparam	JUMP_STATE		= 4'd2;

//
// Define statemachine behaviour
//
always @(posedge update or posedge reset) begin
	if (reset) begin
		xSprite	<= 8'd95;
		ySprite	<= 9'd129;
		IdSprite	<= 4'd0;
		
		state		<= RUN_STATE;
	end else begin
		case (state)
			// set position and update running animation
			RUN_STATE : begin
				xSprite	<= 8'd95;				// player sprite  position is constant during running
				ySprite	<= 9'd129;
				update_running_animation();
				
				// change to jump/crouch state if buttons pressed 
				// (crouch takes priority as it is easier for the player to recover 
				// from in the case of an accidental double click)
				if (!keys[1]) begin
					state		<= CROUCH_STATE;
				end else if (!keys[0]) begin
					velocity	<= 8'd14;			// set initial jump velocity
					state		<= JUMP_STATE;
				end
			end
			
			// set player sprite to crouch
			CROUCH_STATE : begin
				xSprite	<= 8'd73;		// player sprites position is constant during crouch
				ySprite	<= 9'd123;
				IdSprite	<= 4'd4;
 
				//	revert to run state as soon as button released
				if (keys[1]) begin
					state	<= RUN_STATE;
				end
			end
			
			// set player sprite to jump and update velocity/position
			JUMP_STATE : begin 
				xSprite	<= xSprite + velocity;	// update player sprites vertical position based on current velocity
				ySprite	<= 9'd129;
				IdSprite	<= 4'd3;
				velocity	<= velocity - 8'd2;		// reduce velocity each loop
				
				// if the player sprite is about to hit ground return to run state.
				if (velocity[7] == 1 && xSprite <= 111) begin
					state <= RUN_STATE;
				end
			end	
		endcase
	end
end

//
// define statemachine tasks
//
// increment to next running sprite
task update_running_animation () ;
	if (IdSprite < 2) begin
		IdSprite	<= IdSprite + 4'd1;
	end else begin
		IdSprite	<= 4'd0;
	end
endtask

endmodule 