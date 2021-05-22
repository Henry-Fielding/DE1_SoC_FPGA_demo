//
// check collisions 
// ----------------
// By: Henry Fielding
// For: University of Leeds
// Date: 14th May 2021
//
// Short Description
// -----------------
// This module is designed to check for collisions between the player sprite and the obstacle
// based on the position and dimensions of each object.

module CheckCollisions #(
	// declare parameters
	parameter X_BITWIDTH = 8,
	parameter Y_BITWIDTH = 9
)(
	// declare ports
	input							update,
	input							reset,
	input	[X_BITWIDTH-1:0]	xSprite,
	input	[Y_BITWIDTH-1:0]	ySprite,
	input	[3:0]					IdSprite,
	input	[X_BITWIDTH-1:0]	xObstacle,
	input	[Y_BITWIDTH-1:0]	yObstacle,
	input	[3:0]					IdObstacle,

	output reg	collision
);

//
// declare local wires and registers
//
reg	[ 8:0]	widthSprite;
reg	[ 9:0]	heightSprite;
reg	[ 8:0]	widthObstacle;
reg	[ 9:0]	heightObstacle;

//
// declare local parameters
//
localparam WIDTH_STAND		= 32;
localparam HEIGHT_STAND		= 64;
localparam WIDTH_CROUCH		= 36;
localparam HEIGHT_CROUCH	= 42;
localparam OBSTACLE_WIDTH	= 32;
localparam OBSTACLE_HEIGHT	= 32;

//
// Define module logic
//
always @(posedge update) begin
	// set sprite width and height based on sprite iD (crouch == 4 stand != 4)
	if (IdSprite == 4) begin
		widthSprite		<= WIDTH_CROUCH;
		heightSprite	<= HEIGHT_CROUCH;
	end else begin
		widthSprite		<= WIDTH_STAND;
		heightSprite	<= HEIGHT_STAND;
	end
	
	// set obstacle width and height
	widthObstacle	<= OBSTACLE_WIDTH;
	heightObstacle	<= OBSTACLE_HEIGHT;

	// check for overlap of sprite and obstacle
	collision	<= (ySprite < yObstacle + widthObstacle) 
					&& (ySprite + widthSprite > yObstacle) 
					&& (xSprite > xObstacle - heightObstacle) 
					&& (xSprite - heightSprite < xObstacle);
end

endmodule 