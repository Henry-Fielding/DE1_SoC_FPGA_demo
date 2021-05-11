/*
 * Write Pixel
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 11th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to write a pixel to the display at the selected cooridnates
 *
 */
 
module DrawSquare #(
	// declare parameters
	parameter CLOCK_FREQ = 50000000
)(
	// declare ports
	input	[ 7:0]	xOrigin,
	input	[ 8:0]	yOrigin,
	input [ 7:0]	width,
	input [ 8:0]	height,
	input [15:0]	pixelData,
	output 			ready
);

//
// Declare statemachine registers and parameters
//
reg state




endmodule


 



