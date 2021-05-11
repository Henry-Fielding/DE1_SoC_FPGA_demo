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
	
	// LT24 Interface
	output			LT24Wr_n,
	output			LT24Rd_n,
	output			LT24CS_n,
	output			LT24RS,
	output			LT24Reset_n,
	output[15:0]	LT24Data,
	output			LT24LCDOn
);

//
// Instatiate LCD Display
//
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;

LT24Display #(
	.WIDTH		(LCD_WIDTH	),
	.HEIGHT		(LCD_HEIGHT	),
	.CLOCK_FREQ	(CLOCK_FREQ	)
) Display (
	//Clock and Reset In
	.clock			(clock		),
	.globalReset	(globalReset),
	//Reset for User Logic
	.resetApp		(resetApp	),
	//Pixel Interface
	.xAddr			(xAddr		),
	.yAddr			(yAddr		),
	.pixelData		(pixelData	),
	.pixelWrite		(pixelWrite	),
	.pixelReady		(pixelReady	),
	//Use pixel addressing mode
	.pixelRawMode	(1'b0			),
	//Unused Command Interface
	.cmdData			(8'b0			),
	.cmdWrite		(1'b0			),
	.cmdDone			(1'b0			),
	.cmdReady		(				),
	//Display Connections
	.LT24Wr_n		(LT24Wr_n	),
	.LT24Rd_n		(LT24Rd_n	),
	.LT24CS_n		(LT24CS_n	),
	.LT24RS			(LT24RS		),
	.LT24Reset_n	(LT24Reset_n),
	.LT24Data		(LT24Data	),
	.LT24LCDOn		(LT24LCDOn	)
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


 



