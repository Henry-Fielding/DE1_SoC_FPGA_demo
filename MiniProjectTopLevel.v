/*
 * Mini-project Top level
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 11th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to designed to demonstrate the FPGA skills
 * developed throughout this module.
 *
 */
 
module MiniProjectTopLevel (
	input clock,
	input reset,
	
	output				LT24Wr_n,
	output				LT24Rd_n,
	output				LT24CS_n,
	output				LT24RS,
	output				LT24Reset_n,
	output	[15:0]	LT24Data,
	output				LT24LCDOn,
	
	output	[9:0]	LEDs

);

//
// Local Variables
//
reg				draw = 1'b0;
reg	[ 7:0]	xOrigin = 8'd100;
reg	[ 8:0]	yOrigin = 9'd20;
reg	[ 3:0]	ROMId = 8'd1;
//reg	[ 7:0]	width  = 8'd20;
//reg	[ 8:0]	height = 9'd20;
//reg	[15:0]	pixelData = 16'hF800;

wire				ready;

reg [3:0] spriteId = 4'b0;
reg [3:0] layer = 4'b0;
reg refreshScreen = 1'b0;
reg clockhold = 1'b0;

//
// Instatiate Drawsquare module
//
//DrawSquare #(
//	// declare parameters
//	.CLOCK_FREQ (50000000 	)//fix
//) Square1 (
//	// declare ports
//	.clock		(clock		),
//	.reset		(reset		),
//	.draw			(draw			),
//	.xOrigin		(xOrigin		),
//	.yOrigin		(yOrigin		),
//	.width		(width		),
//	.height		(height		),
//	.pixelData	(pixelData	),
//	
//	.ready		(ready		),
//	
//	.LEDs			(LEDs),
//	
//	// LT24 Interface
//	.LT24Wr_n	(LT24Wr_n	),
//	.LT24Rd_n	(LT24Rd_n	),
//	.LT24CS_n	(LT24CS_n	),
//	.LT24RS		(LT24RS		),
//	.LT24Reset_n(LT24Reset_n),
//	.LT24Data	(LT24Data	),
//	.LT24LCDOn	(LT24LCDOn	)
//);

DrawMif #(
	// declare parameters
	.CLOCK_FREQ (50000000 	)//fix
) Square1 (
	// declare ports
	.clock		(clock		),
	.reset		(reset		),
	.draw			(draw			),
	.xOrigin		(xOrigin		),
	.yOrigin		(yOrigin		),
	.ROMId		(ROMId),
	
	.ready		(ready		),
	
	.LEDs			(LEDs),
	
	// LT24 Interface
	.LT24Wr_n	(LT24Wr_n	),
	.LT24Rd_n	(LT24Rd_n	),
	.LT24CS_n	(LT24CS_n	),
	.LT24RS		(LT24RS		),
	.LT24Reset_n(LT24Reset_n),
	.LT24Data	(LT24Data	),
	.LT24LCDOn	(LT24LCDOn	)
);





always @ (posedge clock) begin
	if (clock10hz && (clock10hz != clockhold)) begin
		refreshScreen <= 1'b1;
	end
	clockhold <= clock10hz;
	
	if (draw) begin
		draw <= 1'b0;
	end else if (refreshScreen) begin
		if ((layer == 0) && ready) begin				// draw
			// draw background
			ROMId = 4'd3;
			draw = 1'b1;
			
			layer <= layer + 1'b1;
		end else if ((layer == 1) && ready) begin
			// draw player sprite
			ROMId = spriteId;
			draw = 1'b1;
			
			
			layer <= layer + 1'b1;
		end else if (layer > 1) begin
			refreshScreen <= 1'b0;
			layer <= 4'b0;
		end
		
	end 
end


// update position

always @ (posedge clock10hz) begin
	if (spriteId < 2) begin
		spriteId <= spriteId + 1;
	end else begin
		spriteId <= 0;
	end
end

reg clock10hz = 0;
reg [31:0] clockcounter = 0;

// clock divider 
always @ (posedge clock) begin
		clockcounter <= clockcounter + 32'd1;
		if (clockcounter >= 32'd2500000) begin
			clock10hz <= !clock10hz;
			clockcounter <= 32'd0;
		end
end



endmodule 