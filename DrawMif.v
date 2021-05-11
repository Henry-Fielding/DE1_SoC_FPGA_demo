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
 
module DrawMif #(
	// declare parameters
	parameter CLOCK_FREQ = 50000000
)(
	// declare ports
	input 			clock,
	input				reset,
	input				draw,
	input	[ 7:0]	xOrigin,
	input	[ 8:0]	yOrigin,
	input	[ 7:0]	mifId,
	
	output reg		ready,
	
	output reg	[9:0]	LEDs,
	
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
// Local Variables
//
reg	[ 7:0]	xAddr;
reg	[ 8:0]	yAddr;
reg	[15:0]	pixelData;
wire				pixelReady;
reg				pixelWrite;

//reg 	[7:0]	xArray;
//reg	[8:0]	yArray;

(* ram_init_file = "smiley.mif" *) reg [15:0] smiley [7:0][7:0];
reg [7:0] smileyWidth = 8'd8;
reg [7:0] smileyHeight = 8'd8;




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
	.globalReset	(reset),
	//Reset for User Logic
	.resetApp		(	),
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
reg	[2:0]	state;
localparam	IDLE_STATE			=	3'd0;
localparam	READY_STATE			=	3'd1;
localparam	SET_STATE			=	3'd2;
localparam	WAIT_STATE			=	3'd3;
localparam	INCREMENT_STATE	=	3'd4;


always @(posedge clock) begin
	LEDs[9] <= pixelReady;
end

always @(posedge clock or posedge reset) begin
	if (reset) begin
		pixelWrite <= 1'b0;
		ready <= 1'b0;
		state <= IDLE_STATE;
		LEDs[8:0] <= 9'd32;
	
	end else begin
		case (state)
			IDLE_STATE : begin // wait for last draw signal to end

				LEDs[8:0] <= 9'd1;
				
				if (!draw) begin
					state <= READY_STATE;
				end
			end
			
			READY_STATE : begin // wait for new draw command
				ready <= 1'b1;
				LEDs[8:0] <= 9'd2;
				xAddr <= xOrigin;
				yAddr <= yOrigin;
			
				if (draw) begin
					ready <= 1'b0;
					state <= SET_STATE;
				end
			end
			
			SET_STATE : begin // set current pixel
				pixelData <= smiley[yAddr - yOrigin][xAddr - xOrigin];
				pixelWrite <= 1'b1;
				LEDs[8:0] <= 9'd4;
				if (!pixelReady) begin
					state <= WAIT_STATE;
				end
			end
			
			WAIT_STATE : begin // wait for lcd to finish writing
				LEDs[8:0] <= 9'd8;
				if (pixelReady) begin
					pixelWrite <= 1'b0;
					state <= INCREMENT_STATE;
				end
			end
			
			INCREMENT_STATE : begin // increment pixel
				LEDs[8:0] <= 9'd16;
				if	(xAddr < (xOrigin + (smileyWidth - 1))) begin 				// if not at end of row increment x
					xAddr <= xAddr + 7'b1;
					state <= SET_STATE;
				end else if (yAddr < (yOrigin + (smileyHeight - 1))) begin	// if at end of row reset x, increment y
					yAddr <= yAddr + 8'b1;
					xAddr <= xOrigin;
					state <= SET_STATE;
				end else begin													// if at end of square move to idle
					state <= IDLE_STATE;
				end
				
			end
		endcase
	end
end



endmodule
