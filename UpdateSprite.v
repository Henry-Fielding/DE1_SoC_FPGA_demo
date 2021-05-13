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
	
	output	[ 7:0]	xSprite,
	output	[ 8:0]	ySprite,
	output	[ 3:0]	ROMId;
);

//
// Declare statemachine registers and parameters
//
reg	[3:0]	state;
localparam	STAND_STATE	=	4'd0;
localparam	RUN_STATE	=	4'd1;
localparam	JUMP_STATE	=	4'd1;

always @(posedge update) begin
	
	RUN_STATE : begin
		//task to update ROMid
		//if button pressed move to jump
		if (!Key[0]) begin
			state <= JUMP_STATE;
		end
	end
	
	JUMP_STATE : begin
		ROMId <= 8d'2;
		//	adjust height 
		//	if height = floor move to run
		if (Key[0]) begin
			state <= RUN_STATE;
		end
	end
	
	
end