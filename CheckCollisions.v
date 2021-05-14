/* check collisions 
 * ----------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 14th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to update the position of the obstacle
 *
 */

module CheckCollisions #(
	// declare parameters
	parameter X1_BITWIDTH = 8,
	parameter Y1_BITWIDTH = 8,
	parameter X2_BITWIDTH = 8,
	parameter Y2_BITWIDTH = 8,
	parameter WIDTH_1		= 50,
	parameter HEIGHT_1	= 50,
	parameter WIDTH_2		= 50,
	parameter HEIGHT_2	= 50
)(
	// declare ports
	input						update,	// timing ports
	input						reset,
	input	[X1_BITWIDTH-1:0]	x1,
	input	[Y1_BITWIDTH-1:0]	y1,
	input	[X2_BITWIDTH-1:0]	x2,
	input	[Y2_BITWIDTH-1:0]	y2,

	output reg 		collision //
);

//
// Define module logic
//

always @(posedge update) begin
	if ((x1 < x2 + WIDTH_2) && (x1 + WIDTH_1 > x2) && (y1 < y2 + HEIGHT_2) && (y1 + HEIGHT_1 > y2)) begin
		collision <= 1'b1;
	end else begin
		collision <= 1'b0;
	end

end

endmodule 