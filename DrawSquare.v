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
	input 			clock,
	input				reset,
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
reg	[1:0]	state;
localparam	IDLE_STATE			=	2'd0;
localparam	SET_STATE			=	2'd1;
localparam	WAIT_STATE			=	2'd2;
localparam	INCREMENT_STATE	=	2'd3;

always @(posedge clock or posedge reset) begin
	if (reset) begin
	
	
	end else begin
		case (state)
			IDLE_STATE : begin // wait for next command
				
			end
			
			SET_STATE : begin // set current pixel
				
			end
			
			WAIT_STATE : begin // wait for lcd to finish write
			
			end
			
			INCREMENT_STATE : begin // increment pixel
			
			end
end


endmodule


 



