//
// check collisions 
// ----------------
// By: Henry Fielding
// For: University of Leeds
// Date: 14th May 2021
//
// Short Description
// -----------------
// This module is designed to update the position of the obstacle

module CheckCollisions #(
	// declare parameters
	parameter X1_BITWIDTH = 8,
	parameter Y1_BITWIDTH = 9,
	parameter X2_BITWIDTH = 8,
	parameter Y2_BITWIDTH = 9
)(
	// declare ports
	input						update,
	input						reset,
	input	[X1_BITWIDTH-1:0]	x1,
	input	[Y1_BITWIDTH-1:0]	y1,
	input	[X2_BITWIDTH-1:0]	x2,
	input	[Y2_BITWIDTH-1:0]	y2,
	input [3:0]					spriteId,
	input [3:0]					obstacleId,

	output reg 		collision
);

// declare local registers
reg 	[ 8:0]	width1;
reg	[ 9:0]	height1;
reg 	[ 8:0]	width2;
reg	[ 9:0]	height2;

// declare local parameters
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
	// check sprite position and set dimensions (crouch == 4 stand != 4)
	if (spriteId == 4) begin
		width1	<= WIDTH_CROUCH;
		height1	<= HEIGHT_CROUCH;
	end else begin
		width1	<= WIDTH_STAND;
		height1	<= HEIGHT_STAND;
	end
	width2	<= OBSTACLE_WIDTH;
	height2	<= OBSTACLE_HEIGHT;

	// check collisions
	if ((y1 < y2 + width2) && (y1 + width1 > y2) && (x1 > x2 - height2) && (x1 - height1 < x2)) begin
		collision <= 1'b1;
	end else begin
		collision <= 1'b0;
	end

end

endmodule 